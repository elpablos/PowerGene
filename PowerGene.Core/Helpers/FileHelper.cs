using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PowerGene.Core.Helpers
{
    public static class FileHelper
    {
        public static string GetAbsolutePath(string path)
        {
            if (!System.IO.Path.IsPathRooted(path))
            {
                // System.AppDomain.CurrentDomain.BaseDirectory
                return System.IO.Path.Combine(System.Environment.CurrentDirectory, path);
            }
           
            return path;
        }
    }
}
