using Caliburn.Micro;
using PowerGene.Core.Events;
using PowerGene.Core.Models.Common;
using PowerGene.App.Models.Settings;
using PowerGene.Core.Managers.Projects;
using System.Linq;
using PowerGene.Core.Helpers;

namespace PowerGene.App.ViewModels.Settings
{
    public class SettingViewModel : Screen, ISettingViewModel, IHandle<ProjectEventBase>
    {
        #region Fields

        private SettingModel _Model;
        private readonly IEventAggregator _eventAggregator;
        private readonly IProjectManager _projectManager;
        private readonly IWindowManager _windowManager;

        #endregion

        #region Properties

        public SettingModel Model
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

        public SettingViewModel(IEventAggregator eventAggregator, IProjectManager projectManager, IWindowManager windowManager)
        {
            _eventAggregator = eventAggregator;
            _projectManager = projectManager;
            _windowManager = windowManager;
            _eventAggregator.Subscribe(this);

            Model = new SettingModel();
            Model.PropertyChanged += Model_PropertyChanged;
        }

        private void Model_PropertyChanged(object sender, System.ComponentModel.PropertyChangedEventArgs e)
        {
            if (e.PropertyName == "SelectedScript")
            {
                if (Model.SelectedScript != null)
                {
                    var dict = Model.SelectedScript.Value.ToDictionary().ConvertToNotify();
                    Model.ScriptItems = new BindableCollection<NotifyKeyItemBase>(dict);
                }
            }

            if (e.PropertyName == "SelectedMetadata")
            {
                if (Model.SelectedMetadata != null)
                {
                    var dict = Model.SelectedMetadata.Value.ToDictionary().ConvertToNotify();
                    Model.MetadataItems = new BindableCollection<NotifyKeyItemBase>(dict);
                }
            }
        }

        protected override void OnActivate()
        {
            _eventAggregator.Subscribe(this);
            base.OnActivate();

            InitData();
        }

        protected override void OnDeactivate(bool close)
        {
            if (close)
            {
                _eventAggregator.Unsubscribe(this);
            }
            base.OnDeactivate(close);
        }

        #endregion

        #region Actions

        public void SaveAction()
        {
            //_projectManager.Model.Metadata["AppNamespace"] = Model.AppNamespace;
            //_projectManager.Model.Metadata["CoreNamespace"] = Model.CoreNamespace;
            //_projectManager.Model.Metadata["ConnectionString"] = Model.ConnectionString;
            //_projectManager.Model.Metadata["ProjectName"] = Model.ProjectName;

            _projectManager.Model.Metadata.Clear();
            foreach (var metadata in Model.Metadatas)
            {
                _projectManager.Model.Metadata.Add(metadata.Key, metadata.Value);
            }

            _projectManager.Model.Scripts.Clear();
            foreach (var script in Model.Scripts)
            {
                _projectManager.Model.Scripts.Add(script.Key, script.Value);
            }

            TryClose(true);
        }

        public void CloseAction()
        {
            TryClose(false);
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

        #endregion

        #region Private methods

        private void InitData()
        {
            Model.Metadatas = new BindableCollection<NotifyKeyItemBase>(_projectManager.Model.Metadata.ConvertToNotify());
            Model.Scripts = new BindableCollection<NotifyKeyItemBase>(_projectManager.Model.Scripts.ConvertToNotify());
        }

        #endregion
    }
}
