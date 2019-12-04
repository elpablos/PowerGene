using Caliburn.Micro;
using PowerGene.Core.Events;
using PowerGene.Core.Models.Common;
using PowerGene.Module.MsSQL.Models.Shells.Tables;
using PowerGene.Core.Common;
using PowerGene.Core.Managers.PowerShells;
using PowerGene.Core.Managers.Projects;
using System.Linq;
using PowerGene.Module.MsSQL.Events;

namespace PowerGene.Module.MsSQL.ViewModels.Shells.Tables
{
    public class ShellTableViewModel : TabScreen, IHandle<ProjectEventBase>
    {
        #region Fields

        private const string SCRIPT_LIST_KEY = "Tables";
        private const string DISPLAYNAME = "Tables";
        private const int ORDER = 1;

        private readonly IWindowManager _windowManager;
        private readonly IPowerShellManager _powerShellManager;

        #endregion

        #region Properties

        public override int Order { get { return ORDER; } }

        public override string ModuleKeyName { get { return SCRIPT_LIST_KEY; } }

        private ShellTableModel _Model;
        public ShellTableModel Model
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

        public ShellTableViewModel(IProjectManager projectManager, IEventAggregator eventAggregator, IWindowManager windowManager, IPowerShellManager powerShellManager)
            : base(projectManager, eventAggregator, powerShellManager)
        {
            DisplayName = DISPLAYNAME;
            _windowManager = windowManager;

            Model = new ShellTableModel();
        }

        protected override void OnActivate()
        {
            _eventAggregator.Subscribe(this);
            base.OnActivate();
        }

        protected override void OnDeactivate(bool close)
        {
            if (close)
            {
                _eventAggregator.Unsubscribe(this);
            }
            
            base.OnDeactivate(close);
        }

        protected override void OnInitialize()
        {
        }

        #endregion

        #region Actions

        public void RunScriptAction(object obj)
        {
            RunScript(obj, Model.Actions, Model.SelectedItem, ProjectEvent.TABLES);
        }

        #endregion

        #region IHandle

        public void Handle(ProjectEventBase message)
        {
            if (message.EventType == ProjectEvent.ALL || message.EventType == ProjectEvent.TABLES)
            {
                InitData();
            }
        }

        #endregion

        #region Private methods

        private void InitData()
        {
            Model.Items.Clear();
            Model.Items.AddRange(_projectManager.Model.GetDictOrInit(ModuleKeyName).Values);

            Model.Actions.Clear();

            var actions = ReturnScriptModuleDictionary(ModuleKeyName).ConvertToNotify();
            Model.Actions.AddRange(actions);
        }

        #endregion
    }
}
