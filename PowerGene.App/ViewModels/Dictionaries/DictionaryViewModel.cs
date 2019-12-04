using Caliburn.Micro;
using PowerGene.Core.Events;
using PowerGene.App.Models.Dictionaries;
using PowerGene.Core.Managers.Projects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PowerGene.App.ViewModels.Dictionaries
{
    class DictionaryViewModel : Screen, IDictionaryViewModel, IHandle<ProjectEventBase>
    {
        #region Fields

        private DictionaryModel _Model;
        private readonly IEventAggregator _eventAggregator;
        private readonly IProjectManager _projectManager;
        private readonly IWindowManager _windowManager;

        #endregion

        #region Properties

        public DictionaryModel Model
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

        public DictionaryViewModel(IEventAggregator eventAggregator, IProjectManager projectManager, IWindowManager windowManager)
        {
            _eventAggregator = eventAggregator;
            _projectManager = projectManager;
            _windowManager = windowManager;
            _eventAggregator.Subscribe(this);

            Model = new DictionaryModel();
            Model.PropertyChanged += Model_PropertyChanged;
        }

        private void Model_PropertyChanged(object sender, System.ComponentModel.PropertyChangedEventArgs e)
        {
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
            Model.Originals = Model.Originals
                .Concat(Model.Sources)
                .GroupBy(x => x.Key)
                .ToDictionary(x => x.Key, y => y.First().Value);

            TryClose(true);
        }

        public void RemoveAction()
        {
            if (Model.SelectedItem != null)
            {
                var item = Model.Sources.FirstOrDefault(x => x.Value == Model.SelectedItem);
                Model.Sources.Remove(item.Key);

                Model.Items.Remove(Model.SelectedItem);
            }
        }

        public void CloseAction()
        {
            TryClose(false);
        }

        #endregion

        #region IHandle

        public void Handle(ProjectEventBase message)
        {
            InitData();
        }

        #endregion

        #region Private methods

        private void InitData()
        {
            Model.Items.Clear();
            Model.Items = new BindableCollection<object>(
                Model.Sources
                .Where(x => !Model.Originals.ContainsKey(x.Key))
                .Select(x => x.Value));

        }

        #endregion
    }
}
