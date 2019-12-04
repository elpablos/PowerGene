using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Dynamic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PowerGene.Core.Helpers
{
    /// <summary>
    /// https://gist.github.com/jarrettmeyer/798667/a87f9bcac2ec68541511f17da3c244c0e05bdc49
    /// </summary>
    public static class ObjectToDictionaryHelper
    {
        public static Dictionary<string, object> ToDictionary(this object source)
        {
            return source.ToDictionary<object>();
        }

        public static Dictionary<string, T> ToDictionary<T>(this object source)
        {
            if (source == null) ThrowExceptionWhenSourceArgumentIsNull();

            var dictionary = new Dictionary<string, T>();

            if (source.GetType().Namespace.StartsWith("System"))
            {
                dictionary.Add("_SYSTEM_", (T)source);
            }
            else
            {

                foreach (PropertyDescriptor property in TypeDescriptor.GetProperties(source))
                {
                    object value = property.GetValue(source);
                    if (IsOfType<T>(value))
                    {
                        dictionary.Add(property.Name, (T)value);
                    }
                }
            }

            return dictionary;
        }

        ///// <summary>
        ///// https://stackoverflow.com/a/24381795
        ///// </summary>
        ///// <param name="dict"></param>
        ///// <returns></returns>
        //public static dynamic DictionaryToObject(this IDictionary<string, object> dict)
        //{
        //    IDictionary<string, object> eo = new ExpandoObject() as IDictionary<string, object>;
        //    foreach (KeyValuePair<string, object> kvp in dict)
        //    {
        //        eo.Add(kvp);
        //    }
        //    return eo;
        //}

        public static dynamic DictionaryToObject(this IDictionary<string, object> dict)
        {
            if (dict.Count == 1 && dict.Keys.First() == "_SYSTEM_")
            {
                return dict.First().Value;
            }

            string json = JsonConvert.SerializeObject(dict);
            var project = JsonConvert.DeserializeObject<dynamic>(json);

            return project;
        }

        private static bool IsOfType<T>(object value)
        {
            return value is T;
        }

        private static void ThrowExceptionWhenSourceArgumentIsNull()
        {
            throw new NullReferenceException("Unable to convert anonymous object to a dictionary. The source anonymous object is null.");
        }
    }
}
