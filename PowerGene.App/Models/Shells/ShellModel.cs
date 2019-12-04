using Caliburn.Micro;
using PowerGene.Core.Events;
using PowerGene.Core.Models.Common;
using System.Collections.Concurrent;

namespace PowerGene.App.Models.Shells
{
    /// <summary>
    /// Model - hlavni okno 
    /// </summary>
    public class ShellModel : PropertyChangedBase
    {
        private string _Path;
        public string Path
        {
            get { return _Path; }
            set
            {
                _Path = value;
                NotifyOfPropertyChange();
            }
        }

        private bool _IsDeveloper;
        public bool IsDeveloper
        {
            get { return _IsDeveloper; }
            set
            {
                _IsDeveloper = value;
                NotifyOfPropertyChange();
            }
        }

        private ConcurrentQueue<LogEvent> _Logs;
        public ConcurrentQueue<LogEvent> Logs
        {
            get { return _Logs; }
            set
            {
                _Logs = value;
                NotifyOfPropertyChange();
            }
        }

        private IObservableCollection<NotifyKeyItemBase> _Commands;
        public IObservableCollection<NotifyKeyItemBase> Commands
        {
            get { return _Commands; }
            set
            {
                _Commands = value;
                NotifyOfPropertyChange();
            }
        }

        private IObservableCollection<NotifyKeyItemBase> _FileOperations;
        public IObservableCollection<NotifyKeyItemBase> FileOperations
        {
            get { return _FileOperations; }
            set
            {
                _FileOperations = value;
                NotifyOfPropertyChange();
            }
        }

        private IObservableCollection<NotifyKeyItemBase> _SettingOperations;
        public IObservableCollection<NotifyKeyItemBase> SettingOperations
        {
            get { return _SettingOperations; }
            set
            {
                _SettingOperations = value;
                NotifyOfPropertyChange();
            }
        }

        public ShellModel()
        {
            Logs = new ConcurrentQueue<LogEvent>();
            Commands = new BindableCollection<NotifyKeyItemBase>();
            FileOperations = new BindableCollection<NotifyKeyItemBase>();
            SettingOperations = new BindableCollection<NotifyKeyItemBase>();
        }

    }
}
