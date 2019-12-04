using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PowerGene.Core.Events
{
    public class LogEvent
    {
        public string Text { get; }

        public LogEvent(string text)
        {
            Text = text;
        }
    }
}
