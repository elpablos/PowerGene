using Caliburn.Micro;
using PowerGene.Core.Events;
using PowerGene.Core.Models.Common;
using PowerGene.Module.MsSQL.Models.Shells.Procedures;
using PowerGene.Core.Common;
using PowerGene.Core.Managers.PowerShells;
using PowerGene.Core.Managers.Projects;
using System.Linq;
using PowerGene.Module.MsSQL.Events;

namespace PowerGene.Module.MsSQL.ViewModels.Shells.Procedures
{
    public class ShellProcedureViewModel : TabScreen, IHandle<ProjectEventBase>
    {
        #region Fields

        private const string SCRIPT_LIST_KEY = "Procedures";
        private const string DISPLAYNAME = "Procedures";
        private const int ORDER = 3;

        private readonly IWindowManager _windowManager;
        private readonly IPowerShellManager _powerShellManager;

        #endregion

        #region Properties

        public override int Order { get { return ORDER; } }

        public override string ModuleKeyName { get { return SCRIPT_LIST_KEY; } }

        private ShellProcedureModel _Model;
        public ShellProcedureModel Model
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

        public ShellProcedureViewModel(IProjectManager projectManager, IEventAggregator eventAggregator, IWindowManager windowManager, IPowerShellManager powerShellManager)
            : base(projectManager, eventAggregator, powerShellManager)
        {
            DisplayName = DISPLAYNAME;
            _windowManager = windowManager;

            Model = new ShellProcedureModel();
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
            RunScript(obj, Model.Actions, Model.SelectedItem, ProjectEvent.PROCEDURES);
        }

        #endregion

        #region IHandle

        public void Handle(ProjectEventBase message)
        {
            if (message.EventType == ProjectEvent.ALL || message.EventType == ProjectEvent.PROCEDURES)
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
