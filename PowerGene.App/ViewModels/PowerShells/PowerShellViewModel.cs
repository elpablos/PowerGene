//using Caliburn.Micro;
//using PowerGene.Core.Events;
//using PowerGene.Core.Models.Common;
//using PowerGene.App.Models.PowerShells;
//using PowerGene.Core.Helpers;
//using PowerGene.Core.Managers.PowerShells;
//using PowerGene.Core.Managers.Projects;
//using PowerGene.Core.Models.Projects;

//namespace PowerGene.App.ViewModels.PowerShells
//{
//    public class PowerShellViewModel : Screen, IPowerShellViewModel, IHandle<ProjectEventBase>
//    {
//        #region Fields

//        private PowerShellModel _Model;
//        private readonly IEventAggregator _eventAggregator;
//        private readonly IProjectManager _projectManager;
//        private readonly IWindowManager _windowManager;
//        private readonly IPowerShellManager _powerShellManager;

//        #endregion

//        #region Properties

//        public PowerShellModel Model
//        {
//            get { return _Model; }
//            set
//            {
//                _Model = value;
//                NotifyOfPropertyChange();
//            }
//        }

//        #endregion

//        #region Constructor

//        public PowerShellViewModel(IEventAggregator eventAggregator, IProjectManager projectManager, IWindowManager windowManager, IPowerShellManager powerShellManager)
//        {
//            _eventAggregator = eventAggregator;
//            _projectManager = projectManager;
//            _windowManager = windowManager;
//            _powerShellManager = powerShellManager;
//            _eventAggregator.Subscribe(this);

//            Model = new PowerShellModel();
//            Model.PropertyChanged += Model_PropertyChanged;
//        }

//        private void Model_PropertyChanged(object sender, System.ComponentModel.PropertyChangedEventArgs e)
//        {
//            if (e.PropertyName == "SelectedResult")
//            {
//                if (Model.SelectedResult != null)
//                {
//                    var dict = Model.SelectedResult.Value.ToDictionary().ConvertToNotify();
//                    Model.ResultItems = new BindableCollection<NotifyKeyItemBase>(dict);
//                }
//            }
//        }

//        protected override void OnActivate()
//        {
//            _eventAggregator.Subscribe(this);
//            base.OnActivate();

//            InitData();
//        }

//        protected override void OnDeactivate(bool close)
//        {
//            if (close)
//            {
//                _eventAggregator.Unsubscribe(this);
//            }
//            base.OnDeactivate(close);
//        }

//        #endregion

//        #region Actions

//        public void RunAction()
//        {
//            var model = _powerShellManager.RunScript<ProjectModel>(Model.Script, _projectManager.Clone());
//            var dict = model.Tables.ConvertToNotify();
//            Model.Results = new BindableCollection<NotifyKeyItemBase>(dict);
//        }

//        public void SaveAction()
//        {
//            _powerShellManager.SaveScript(Model.ScriptPath, Model.Script);
//            TryClose(true);
//        }

//        public void CloseAction()
//        {
//            TryClose(false);
//        }

//        #endregion

//        #region IHandle

//        public void Handle(ProjectEventBase message)
//        {
//            if (message.EventType == ProjectEventBase.ALL || message.EventType == ProjectEventBase.BASE)
//            {
//                InitData();
//            }
//        }

//        #endregion

//        #region Private methods

//        private void InitData()
//        {
//            Model.Script = _powerShellManager.ReadScript(Model.ScriptPath);
//        }

//        #endregion
//    }
//}
