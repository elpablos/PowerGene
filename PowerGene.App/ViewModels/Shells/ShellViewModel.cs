using Caliburn.Micro;
using PowerGene.Core.Events;
using PowerGene.App.Models.Shells;
using PowerGene.App.ViewModels.Settings;
using PowerGene.Core.Common;
using PowerGene.Core.Managers.PowerShells;
using PowerGene.Core.Managers.Projects;
using System;
using System.Collections.Generic;
using System.Linq;
using PowerGene.Core.Helpers;
using PowerGene.Core.Models.Common;
using System.Collections;

namespace PowerGene.App.ViewModels.Shells
{
    public class ShellViewModel : Conductor<IScreen>.Collection.OneActive, IShellViewModel, IHandle<ProjectEventBase>, IHandle<LogEvent>
    {
        #region Fields

        protected const string PROJECT_NAME_KEY = "ProjectName";
        protected const string INITIALIZE_SCRIPT_KEY = "InitializeScript";
        protected const string COMMANDS_SECTION_KEY = "Commands";
        protected const string FILE_OPERATIONS_SECTION_KEY = "FileOperations";
        protected const string SETTING_OPERATIONS_SECTION_KEY = "SettingOperations";

        private ShellModel _Model;
        private readonly IEventAggregator _eventAggregator;
        private readonly IProjectManager _projectManager;
        private readonly IWindowManager _windowManager;
        private readonly IPowerShellManager _powerShellManager;

        #endregion

        #region Properties

        public ShellModel Model
        {
            get { return _Model; }
            set
            {
                _Model = value;
                NotifyOfPropertyChange();
            }
        }

        #endregion

        #region Constructor

        public ShellViewModel(ICollection<ITabView> screens, IEventAggregator eventAggregator, 
            IProjectManager projectManager, IWindowManager windowManager, IPowerShellManager powerShellManager)
        {
            var ordederedScreens = screens.OrderBy(x => x.Order);
            Items.AddRange(ordederedScreens);

            _eventAggregator = eventAggregator;
            _projectManager = projectManager;
            _windowManager = windowManager;
            _powerShellManager = powerShellManager;

            Model = new ShellModel();
            _eventAggregator.Subscribe(this);

            SetWindowTitle();

            _powerShellManager.Message += ((s, e) => _eventAggregator.PublishOnCurrentThread(new LogEvent(e)));
        }

        protected override void OnActivate()
        {
            _eventAggregator.Subscribe(this);
            base.OnActivate();
        }

        protected override void OnDeactivate(bool close)
        {
            _eventAggregator.Unsubscribe(this);
            base.OnDeactivate(close);
        }

        protected override void OnInitialize()
        {
            base.OnInitialize();

            // asociavany soubor
            string[] args = Environment.GetCommandLineArgs();
            if (args.GetLength(0) > 1)
            {
                LogManager.GetLog(typeof(ShellViewModel)).Warn(string.Join(" ", args));
                if (args[1].EndsWith(".pwgen"))
                {
                    Model.Path = args[1];
                }
            }

            if (Model.Path != null)
            {
                LoadAction(Model.Path);
            }

            InicializeScript();

            _eventAggregator.PublishOnCurrentThread(new ProjectEventBase
            (
                _projectManager.Model,
                ProjectEventBase.ALL
            ));
        }

        private void InicializeScript()
        {
            var beforeScript = ReturnScriptDictionary(INITIALIZE_SCRIPT_KEY);
            if (beforeScript != null && beforeScript.ContainsKey("Path"))
            {
                string cmd = beforeScript["Path"].ToString();
                // cmd = _powerShellManager.ReadScript(scriptPath);

                _powerShellManager.RunCommand<object>(cmd, _projectManager.Model);
            }
        }

        #endregion

        #region Actions

        public void SettingAction()
        {
            var vm = IoC.Get<ISettingViewModel>();
            if (_windowManager.ShowDialog(vm) == true)
            {
                _eventAggregator.PublishOnCurrentThread(new ProjectEventBase
                (
                    _projectManager.Model,
                    ProjectEventBase.BASE
                ));
            }
        }

        public void LoadAction()
        {
            if (_projectManager.Model != null)
            {
                LoadAction(_projectManager.Model.Path);
            }
        }

        public void LoadAction(string path)
        {
            if (path != null)
            {
                string directory = System.IO.Path.GetDirectoryName(path);
                _projectManager.Read(path);

                // location
                string cmd = $"Set-Location \"{directory}\"";
                _powerShellManager.RunCommand<object>(cmd, _projectManager.Model);

                InicializeScript();

                System.Environment.CurrentDirectory = directory;

                _eventAggregator.PublishOnCurrentThread(new ProjectEventBase
                (
                    _projectManager.Model,
                    ProjectEventBase.ALL
                ));
            }
        }

        public void RunScript(string script)
        {
            _powerShellManager.RunCommand<object>(script, _projectManager.Model);
        }

        public void SaveAction()
        {
            _projectManager.Save();
        }

        public void RunScriptAction(object obj)
        {
            if (obj != null && obj is NotifyKeyItemBase)
            {
                dynamic objz = obj.ToDictionary().DictionaryToObject();

                string key = objz.Key;
                string scriptPath = objz.Value.Path;
                bool hasData = objz.Value.HasData ?? false;

                Hashtable model = _powerShellManager.Run<Hashtable>(scriptPath, _projectManager.Model);
                if (hasData)
                {
                    try
                    {
                        var projectModel = _projectManager.Reload(model);
                        _eventAggregator.PublishOnUIThread(new ProjectEventBase
                        (
                            projectModel,
                            ProjectEventBase.ALL
                        ));
                    }
                    catch (Exception e)
                    {
                        _eventAggregator.PublishOnCurrentThread(new LogEvent(e.Message));
                    }
                }
            }
        }

        #endregion

        #region IHandle

        public void Handle(ProjectEventBase message)
        {
            if (message.EventType == ProjectEventBase.ALL || message.EventType == ProjectEventBase.BASE)
            {
                InitData();
            }
        }

        public void Handle(LogEvent log)
        {
            Model.Logs.Enqueue(log);
        }

        #endregion

        #region Private methods

        private void InitData()
        {
            Model.Path = _projectManager.Model.Path;
            Model.IsDeveloper = _projectManager.Model.IsDeveloper;

            Model.Commands.Clear();
            var commands = ReturnScriptDictionary(COMMANDS_SECTION_KEY).ConvertToNotify();
            Model.Commands.AddRange(commands);

            Model.FileOperations.Clear();
            var fileOperations = ReturnScriptDictionary(FILE_OPERATIONS_SECTION_KEY).ConvertToNotify();
            Model.FileOperations.AddRange(fileOperations);

            Model.SettingOperations.Clear();
            var settingOperations = ReturnScriptDictionary(SETTING_OPERATIONS_SECTION_KEY).ConvertToNotify();
            Model.SettingOperations.AddRange(settingOperations);

            SetWindowTitle();
        }

        private void SetWindowTitle()
        {
            var projectName = _projectManager.Model.Metadata.ContainsKey(PROJECT_NAME_KEY) ? _projectManager.Model.Metadata[PROJECT_NAME_KEY] : "Unknown";
            DisplayName = $"PowerGene | {projectName}";
        }

        protected virtual Dictionary<string, object> ReturnScriptDictionary(string key)
        {
            var result = new Dictionary<string, object>();

            var commands = _projectManager.Model.Scripts.ContainsKey(key) ? _projectManager.Model.Scripts[key] : null;
            if (commands == null) return result;

            result = commands.ToDictionary();

            return result;
        }

        #endregion
    }
}
