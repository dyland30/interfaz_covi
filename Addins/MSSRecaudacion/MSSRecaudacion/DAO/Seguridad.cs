using System;
using System.Collections.Generic;
using System.Text;
using System.Security.Cryptography;

namespace MSSRecaudacion
{
    public class Seguridad
    {
        private byte[] bytPK = (new PasswordDeriveBytes("MSS", null)).GetBytes(32);
                
        public string Encriptar(string strEncriptar)
        {

            Rijndael miRijndael = Rijndael.Create();
            byte[] encrypted = null;
            byte[] returnValue = null;

            try
            {
                miRijndael.Key = bytPK;
                miRijndael.GenerateIV();

                byte[] toEncrypt = System.Text.Encoding.UTF8.GetBytes(strEncriptar);
                encrypted = (miRijndael.CreateEncryptor()).TransformFinalBlock(toEncrypt, 0, toEncrypt.Length);

                returnValue = new byte[miRijndael.IV.Length + encrypted.Length];
                miRijndael.IV.CopyTo(returnValue, 0);
                encrypted.CopyTo(returnValue, miRijndael.IV.Length);
            }
            finally
            {
                miRijndael.Clear();
            }

            return Convert.ToBase64String(returnValue);
        }

        public string Desencriptar(string strDesEncriptar)
        {

            byte[] bytDesEncriptar = Convert.FromBase64String(strDesEncriptar);
            Rijndael miRijndael = Rijndael.Create();
            byte[] tempArray = new byte[miRijndael.IV.Length];
            byte[] encrypted = new byte[bytDesEncriptar.Length - miRijndael.IV.Length];

            string returnValue = String.Empty;

            try
            {
                miRijndael.Key = bytPK;

                Array.Copy(bytDesEncriptar, tempArray, tempArray.Length);
                Array.Copy(bytDesEncriptar, tempArray.Length, encrypted, 0, encrypted.Length);
                miRijndael.IV = tempArray;

                returnValue = System.Text.Encoding.UTF8.GetString((miRijndael.CreateDecryptor()).TransformFinalBlock(encrypted, 0, encrypted.Length));
            }
            finally
            {
                miRijndael.Clear();
            }

            return returnValue;
        }
    }
}
