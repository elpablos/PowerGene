using Caliburn.Micro;
using PowerGene.Core.Models.Common;
using PowerGene.Core.Common;
using PowerGene.Core.Managers.PowerShells;
using PowerGene.Core.Managers.Projects;
using PowerGene.Module.ItemList.Models.Shells.Items;
using PowerGene.Core.Events;
using PowerGene.Module.ItemList.Events;

namespace PowerGene.Module.ItemList.ViewModels.Shells.Items
{
    public class ShellItemViewModel : TabScreen, IHandle<ProjectEventBase>
    {
        #region Fields

        private const string SCRIPT_LIST_KEY = "Items";
        private const string DISPLAYNAME = "Items";
        private const int ORDER = 1;

        private readonly IWindowManager _windowManager;

        #endregion

        #region Properties

        public override int Order { get { return ORDER; } }

        public override string ModuleKeyName { get { return SCRIPT_LIST_KEY; } }

        private ShellItemModel _Model;
        public ShellItemModel Model
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

        public ShellItemViewModel(IProjectManager projectManager, IEventAggregator eventAggregator, IWindowManager windowManager, IPowerShellManager powerShellManager)
            : base(projectManager, eventAggregator, powerShellManager)
        {
            DisplayName = DISPLAYNAME;
            _windowManager = windowManager;

            Model = new ShellItemModel();
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

        public virtual void RunScriptAction(object obj)
        {
            RunScript(obj, Model.Actions, Model.SelectedItem, ProjectEvent.ITEMS);
        }

        #endregion

        #region IHandle

        public void Handle(ProjectEventBase message)
        {
            if (message.EventType == ProjectEvent.ALL || message.EventType == ProjectEvent.ITEMS)
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
