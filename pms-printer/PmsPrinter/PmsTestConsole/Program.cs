﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Brilliantech.Framwork.Utils.ConfigUtil;
using System.IO;
using Brilliantech.ReportGenConnector;
using TECIT.TFORMer;

namespace PmsTestConsole
{
    class Program
    {
        static void Main(string[] args)
        {
            string printer = Console.ReadLine();

            Console.WriteLine(printer);
           // ConfigUtil config = new ConfigUtil("help.sdc");
           //// Console.WriteLine(config.Get("Host"));
           // Console.WriteLine(config.Notes());
           // foreach (string node in config.Notes()) {
           //     Console.WriteLine(node);
           //     Console.WriteLine(config.Get("Host",node));
           // }
           // foreach (string f in Directory.GetFiles(AppDomain.CurrentDomain.BaseDirectory, "*.sdc").ToList()) {
           //     Console.WriteLine(f);
           // }
            
           // Console.WriteLine(DateTime.Now.ToString("HHmmsss"));

         //   Console.WriteLine("J_0001,9".Split(',')[0].TrimStart("J_".ToCharArray()));
            try
            {
                RecordSet rs = new RecordSet();
                RecordData rd = new RecordData();
                rd.Add("A", "AAA");
                rs.Add(rd);
                if (printer.Length == 0) {
                    printer = "Zebra ZM400 (203 dpi) - ZPL";
                }
                IReportGen gen = new TecITGener();
                ReportGenConfig config = new ReportGenConfig()
                {
                     //Printer = "Microsoft XPS Document Writer",
                    //Printer = "Zebra ZM400 (203 dpi) - ZPL (副本 3)",
                    Printer=printer,
                    NumberOfCopies = 1,
                    PrinterType = (PrinterType)0,
                    Template = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Template\\t1.tff")
                };

                gen.Print(rs, config);
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
                Console.Read();
            }
        }
    }
}
