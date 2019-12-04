using Caliburn.Micro;
using PowerGene.Core.Events;
using PowerGene.Core.Models.Common;
using PowerGene.Core.Common;
using PowerGene.Core.Managers.PowerShells;
using PowerGene.Core.Managers.Projects;
using System.Linq;
using PowerGene.Module.MsSQL.Events;

namespace PowerGene.Module.MsSQL.ViewModels.Shells.Views
{
    public class ShellViewViewModel : TabScreen, IHandle<ProjectEventBase>
    {
        #region Fields

        private const string SCRIPT_LIST_KEY = "Views";
        private const string DISPLAYNAME = "Views";
        private const int ORDER = 2;
        
        private readonly IWindowManager _windowManager;
        private readonly IPowerShellManager _powerShellManager;

        #endregion

        #region Properties

        public override int Order { get { return ORDER; } }

        public override string ModuleKeyName { get { return SCRIPT_LIST_KEY; } }

        private PowerGene.Module.MsSQL.Models.Shells.Views.ShellViewModel _Model;
        public PowerGene.Module.MsSQL.Models.Shells.Views.ShellViewModel Model
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

        public ShellViewViewModel(IProjectManager projectManager, IEventAggregator eventAggregator, IWindowManager windowManager, IPowerShellManager powerShellManager)
            : base(projectManager, eventAggregator, powerShellManager)
        {
            DisplayName = DISPLAYNAME;
            _windowManager = windowManager;

            Model = new PowerGene.Module.MsSQL.Models.Shells.Views.ShellViewModel();
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
        }

        #endregion

        #region Actions

        public void RunScriptAction(object obj)
        {
            RunScript(obj, Model.Actions, Model.SelectedItem, ProjectEvent.VIEWS);
        }

        #endregion

        #region IHandle

        public void Handle(ProjectEventBase message)
        {
            if (message.EventType == ProjectEvent.ALL || message.EventType == ProjectEvent.VIEWS)
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
