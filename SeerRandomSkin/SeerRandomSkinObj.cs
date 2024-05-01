﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SeerRandomSkin
{
    /// <summary>
    /// 给 js 层调用的对象
    /// </summary>
    internal class SeerRandomSkinObj
    {
        public void GetCloth(string bag)
        {
            FormPetBag.SeerCloth = bag;
        }

        public void ScreenShot()
        {
            if (Form1.childFormScreenShot == null) return;
            Form1.childFormScreenShot.ScreenShot();
        }

        public void GetRecvPackArray(string pack)
        {
            Form1.childFormPack.ShowRecvPack(pack);
        }

        public void GetSendPackArray(string pack)
        {
            Form1.childFormPack.ShowRecvSend(pack);
        }
    }
}
