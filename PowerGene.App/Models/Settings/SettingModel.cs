using Caliburn.Micro;
using PowerGene.Core.Models.Common;

namespace PowerGene.App.Models.Settings
{
    /// <summary>
    /// Model - nastavení 
    /// </summary>
    public class SettingModel : PropertyChangedBase
    {
        //private string _ConnectionString;
        //public string ConnectionString
        //{
        //    get { return _ConnectionString; }
        //    set
        //    {
        //        _ConnectionString = value;
        //        NotifyOfPropertyChange();
        //    }
        //}

        //private string _ProjectName;
        //public string ProjectName
        //{
        //    get { return _ProjectName; }
        //    set
        //    {
        //        _ProjectName = value;
        //        NotifyOfPropertyChange();
        //    }
        //}

        //private string _AppNamespace;
        //public string AppNamespace
        //{
        //    get { return _AppNamespace; }
        //    set
        //    {
        //        _AppNamespace = value;
        //        NotifyOfPropertyChange();
        //    }
        //}

        //private string _CoreNamespace;
        //public string CoreNamespace
        //{
        //    get { return _CoreNamespace; }
        //    set
        //    {
        //        _CoreNamespace = value;
        //        NotifyOfPropertyChange();
        //    }
        //}

        private NotifyKeyItemBase _SelectedMetadataItem;
        public NotifyKeyItemBase SelectedMetadataItem
        {
            get { return _SelectedMetadataItem; }
            set
            {
                _SelectedMetadataItem = value;
                NotifyOfPropertyChange();
            }
        }

        private IObservableCollection<NotifyKeyItemBase> _MetadataItems;
        public IObservableCollection<NotifyKeyItemBase> MetadataItems
        {
            get { return _MetadataItems; }
            set
            {
                _MetadataItems = value;
                NotifyOfPropertyChange();
            }
        }

        private NotifyKeyItemBase _SelectedMetadata;
        public NotifyKeyItemBase SelectedMetadata
        {
            get { return _SelectedMetadata; }
            set
            {
                _SelectedMetadata = value;
                NotifyOfPropertyChange();
            }
        }

        private IObservableCollection<NotifyKeyItemBase> _Metadatas;
        public IObservableCollection<NotifyKeyItemBase> Metadatas
        {
            get { return _Metadatas; }
            set
            {
                _Metadatas = value;
                NotifyOfPropertyChange();
            }
        }

        private NotifyKeyItemBase _SelectedScript;
        public NotifyKeyItemBase SelectedScript
        {
            get { return _SelectedScript; }
            set
            {
                _SelectedScript = value;
                NotifyOfPropertyChange();
            }
        }

        private IObservableCollection<NotifyKeyItemBase> _Scripts;
        public IObservableCollection<NotifyKeyItemBase> Scripts
        {
            get { return _Scripts; }
            set
            {
                _Scripts = value;
                NotifyOfPropertyChange();
            }
        }

        private NotifyKeyItemBase _SelectedScriptItem;
        public NotifyKeyItemBase SelectedScriptItem
        {
            get { return _SelectedScriptItem; }
            set
            {
                _SelectedScriptItem = value;
                NotifyOfPropertyChange();
            }
        }

        private IObservableCollection<NotifyKeyItemBase> _ScriptItems;
        public IObservableCollection<NotifyKeyItemBase> ScriptItems
        {
            get { return _ScriptItems; }
            set
            {
                _ScriptItems = value;
                NotifyOfPropertyChange();
            }
        }


        public SettingModel()
        {
            Metadatas = new BindableCollection<NotifyKeyItemBase>();
            Scripts = new BindableCollection<NotifyKeyItemBase>();
            ScriptItems = new BindableCollection<NotifyKeyItemBase>();
        }
    }
}
