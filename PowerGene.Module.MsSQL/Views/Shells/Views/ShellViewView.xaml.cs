using PowerGene.Core.Models.Common;
using System.Globalization;
using System.Windows.Controls;
using System.Windows.Data;

namespace PowerGene.Module.MsSQL.Views.Shells.Views
{
    /// <summary>
    /// Interaction logic for ViewView.xaml
    /// </summary>
    public partial class ShellViewView : UserControl
    {
        public ShellViewView()
        {
            InitializeComponent();
        }

        private void FilterButton_Click(object sender, System.Windows.RoutedEventArgs e)
        {
            // StartsWith(txtDisplayNameFilter.Text, StringComparison.InvariantCultureIgnoreCase)

            var viewSource = (CollectionViewSource)this.FindResource("ItemSource");
            CultureInfo culture = CultureInfo.InvariantCulture;
            viewSource.View.Filter = (x) => (
            culture.CompareInfo
                .IndexOf(
                ((string)((dynamic)x).DisplayName.Value),
                txtDisplayNameFilter.Text,
                CompareOptions.IgnoreCase) >= 0);
        }

        private void ActionContextSource_Filter(object sender, FilterEventArgs e)
        {
            e.Accepted = (bool)((e.Item as NotifyKeyItemBase).Value as dynamic).IsContext;
        }

        private void ActionNonContextSource_Filter(object sender, FilterEventArgs e)
        {
            e.Accepted = !(bool)((e.Item as NotifyKeyItemBase).Value as dynamic).IsContext;
        }
    }
}
