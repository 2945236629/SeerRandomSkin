﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SocketHack
{
    public partial class FormScreenShot : Form
    {
        private const int titleAndMenuHeight = 60;

        public FormScreenShot()
        {
            InitializeComponent();
        }

        private void FormScreenShot_Load(object sender, EventArgs e)
        {
            WindowState = FormWindowState.Minimized;
            MainClass.StartHook();
        }

        public void ScreenShot()
        {
            /*作者：羽叔知创
                链接：https://www.zhihu.com/question/592163791/answer/2957995217
                来源：知乎
                著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。*/

            // 获取屏幕宽度和高度
            Width = MainClass.mainWidth / 2;
            Height = MainClass.mainHeight - titleAndMenuHeight;

            // 创建一个屏幕图像对象
            using (Bitmap bitmap = new Bitmap(Width, Height))
            {
                using (Graphics graphics = Graphics.FromImage(bitmap))
                {
                    // 拷贝屏幕图像到位图中
                    graphics.CopyFromScreen(MainClass.mainX + Width, MainClass.mainY + titleAndMenuHeight, 0, 0, new System.Drawing.Size(Width, Height));

                    // 在本窗口中显示
                    pictureBox1.Dock = DockStyle.Fill;
                    pictureBox1.Image = Image.FromHbitmap(bitmap.GetHbitmap());
                }
            }
        }
    }
}