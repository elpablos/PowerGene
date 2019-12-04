using Caliburn.Micro;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PowerGene.Core.Common
{
    public interface ITabView : IScreen
    {
        int Order { get; }
    }
}
