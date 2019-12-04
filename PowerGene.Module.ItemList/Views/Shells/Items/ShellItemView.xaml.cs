using PowerGene.Core.Models.Common;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace PowerGene.Module.ItemList.Views.Shells.Items
{
    /// <summary>
    /// Interaction logic for ShellItemView.xaml
    /// </summary>
    public partial class ShellItemView : UserControl
    {
        public ShellItemView()
        {
            InitializeComponent();
        }

        private void FilterButton_Click(object sender, System.Windows.RoutedEventArgs e)
        {
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
