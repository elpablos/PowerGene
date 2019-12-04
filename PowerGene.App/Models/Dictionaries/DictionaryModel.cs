using Caliburn.Micro;
using System.Collections.Generic;

namespace PowerGene.App.Models.Dictionaries
{
    public class DictionaryModel : PropertyChangedBase
    {
        public Dictionary<string, object> Originals { get; set; }

        public Dictionary<string, object> Sources { get; set; }

        private IObservableCollection<object> _Items;
        public IObservableCollection<object> Items
        {
            get { return _Items; }
            set
            {
                _Items = value;
                NotifyOfPropertyChange();
            }
        }

        private object _SelectedItem;
        public object SelectedItem
        {
            get { return _SelectedItem; }
            set
            {
                _SelectedItem = value;
                NotifyOfPropertyChange();
            }
        }

        public DictionaryModel()
        {
            Sources = new Dictionary<string, object>();
            Originals = new Dictionary<string, object>();
            Items = new BindableCollection<object>();
        }
    }
}
