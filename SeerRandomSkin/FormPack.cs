﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SeerRandomSkin
{
    public partial class FormPack : Form
    {
        public FormPack()
        {
            InitializeComponent();
        }

        private void FormPack_Load(object sender, EventArgs e)
        {
            checkBoxHideRecv.Checked = true;
            checkBoxHideSend.Checked = true;
        }

        private void checkBoxHideRecv_MouseClick(object sender, MouseEventArgs e)
        {
            Form1.chromiumBrowser.GetBrowser().MainFrame.ExecuteJavaScriptAsync("WxSeerUtil.HideRecv = !WxSeerUtil.HideRecv;");
        }

        private void checkBoxHideSend_MouseClick(object sender, MouseEventArgs e)
        {
            Form1.chromiumBrowser.GetBrowser().MainFrame.ExecuteJavaScriptAsync("WxSeerUtil.HideSend = !WxSeerUtil.HideSend;");
        }

        public void ShowRecvPack(string pack)
        {
            var item = new ListViewItem();
            item.Text = "收";
            item.SubItems.Add(pack);
            listViewPack.Items.Add(item);
        }

        public void ShowRecvSend(string pack)
        {
            var item = new ListViewItem();
            item.Text = "发";
            item.SubItems.Add(pack);
            listViewPack.Items.Add(item);
        }

        private void button1_Click(object sender, EventArgs e)
        {
            listViewPack.Items.Clear();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            if (listViewPack.SelectedItems.Count > 0)
            {
                Clipboard.SetDataObject(listViewPack.SelectedItems[0].SubItems[1].Text);
            }
        }
    }
}
