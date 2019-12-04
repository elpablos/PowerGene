using System.ComponentModel;
using System.Linq;

namespace PowerGene.Core.Models.Common
{
    /// <summary>
    /// Inspired by PropertyChangedBase.cs in Caliburn.Micro
    /// </summary>
    public class NotifyKeyItemBase
    {
        private string _Key;
        public string Key
        {
            get { return _Key; }
            set
            {
                _Key = value;
                NotifyOfPropertyChange();
            }
        }

        private object _Value;
        public object Value
        {
            get { return _Value; }
            set
            {
                _Value = value;
                NotifyOfPropertyChange();
            }
        }

        /// <summary>
        /// Occurs when a property value changes.
        /// </summary>
        public virtual event PropertyChangedEventHandler PropertyChanged;

        /// <summary>
        /// Notifies subscribers of the property change.
        /// </summary>
        /// <param name = "propertyName">Name of the property.</param>
        public virtual void NotifyOfPropertyChange([System.Runtime.CompilerServices.CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }

    public static class NotifyKeyItemBaseExtension
    {
        public static NotifyKeyItemBase ConvertToNotify(this System.Collections.Generic.KeyValuePair<string, object> pair)
        {
            return new NotifyKeyItemBase() { Key = pair.Key, Value = pair.Value };
        }

        public static System.Collections.Generic.IEnumerable<NotifyKeyItemBase> ConvertToNotify(this System.Collections.Generic.Dictionary<string, object> dict)
        {
            return dict.Select(x => x.ConvertToNotify());
        }
    }
}
