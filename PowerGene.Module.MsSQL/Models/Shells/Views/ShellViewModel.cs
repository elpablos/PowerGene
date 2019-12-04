using Caliburn.Micro;
using PowerGene.Core.Models.Common;

namespace PowerGene.Module.MsSQL.Models.Shells.Views
{
    public class ShellViewModel : PropertyChangedBase
    {
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


        private IObservableCollection<NotifyKeyItemBase> _Actions;
        public IObservableCollection<NotifyKeyItemBase> Actions
        {
            get { return _Actions; }
            set
            {
                _Actions = value;
                NotifyOfPropertyChange();
            }
        }

        public ShellViewModel()
        {
            Items = new BindableCollection<object>();
            Actions = new BindableCollection<NotifyKeyItemBase>();
        }
    }
}
