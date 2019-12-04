using Caliburn.Micro;
using PowerGene.Core.Models.Common;
using System;
using System.Collections.Generic;

namespace PowerGene.App.Models.PowerShells
{
    /// <summary>
    /// Model - powershell window
    /// </summary>
    public class PowerShellModel : PropertyChangedBase
    {
        private string _ScriptPath;
        public string ScriptPath
        {
            get { return _ScriptPath; }
            set
            {
                _ScriptPath = value;
                NotifyOfPropertyChange();
            }
        }

        private string _Script;
        public string Script
        {
            get { return _Script; }
            set
            {
                _Script = value;
                NotifyOfPropertyChange();
            }
        }

        private string _Result;
        public string Result
        {
            get { return _Result; }
            set
            {
                _Result = value;
                NotifyOfPropertyChange();
            }
        }

        private IObservableCollection<NotifyKeyItemBase> _Results;
        public IObservableCollection<NotifyKeyItemBase> Results
        {
            get { return _Results; }
            set
            {
                _Results = value;
                NotifyOfPropertyChange();
            }
        }

        private NotifyKeyItemBase _SelectedResult;
        public NotifyKeyItemBase SelectedResult
        {
            get { return _SelectedResult; }
            set
            {
                _SelectedResult = value;
                NotifyOfPropertyChange();
            }
        }

        private IObservableCollection<NotifyKeyItemBase> _ResultItems;
        public IObservableCollection<NotifyKeyItemBase> ResultItems
        {
            get { return _ResultItems; }
            set
            {
                _ResultItems = value;
                NotifyOfPropertyChange();
            }
        }

        private NotifyKeyItemBase _SelectedResultItem;
        public NotifyKeyItemBase SelectedResultItem
        {
            get { return _SelectedResultItem; }
            set
            {
                _SelectedResultItem = value;
                NotifyOfPropertyChange();
            }
        }

        public PowerShellModel()
        {
            Results = new BindableCollection<NotifyKeyItemBase>();
        }
    }
}
