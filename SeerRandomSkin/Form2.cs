﻿using System;
using System.Windows.Forms;

namespace SeerRandomSkin
{
    public partial class Form2 : Form
    {
        public Form2()
        {
            InitializeComponent();
        }

        private void Form2_Load(object sender, EventArgs e)
        {
            richTextBox1.Text =
                "作者：https://space.bilibili.com/435657414\n" +
                "开源地址：https://github.com/wx11-00-1/SeerRandomSkin\n" +
                "\n" +
                "# 说明\n" +
                "- 本程序完全开源，免费使用\n" +
                "- 全屏快捷键 F11\n" +
                "- Flash 端可以通过点击商城，召唤小助手蒂朵，能借绿火、治疗背包中的精灵哦！\n" +
                "- 登录器所在目录下的 cache 文件夹保存了浏览数据，请勿转发给他人；删掉的话类似清理缓存的效果（一般不需要清理）\n" +
                "\n" +
                "# 配置\n" +
                "手动点击右下角保存按钮，重新打开登录器才能生效\n\n" +
                "## 随机皮肤相关\n" +
                "- 只在 Flash 端，对 1000 序号及以后的精灵生效\n" +
                "- 默认只使用 2000 序号以前的精灵皮肤，动画大多比较流畅；可以修改皮肤列表，只用自己喜欢的皮肤\n" +
                "- 皮肤黑名单 在 更新皮肤数据 时生效；更新是从 H5 端的一个 json 文件中获取所有皮肤，其中包含无法访问、缺少攻击动画的皮肤，难以自动筛选，请自行添加到黑名单中\n" +
                "- 对皮肤序号范围的限制也是在更新皮肤数据时生效\n" +
                "- 可以单独设置某些精灵不随机换肤\n" +
                "\n" +
                "## 自定义窗口尺寸\n" +
                "- 与网页缩放搭配使用\n" +
                "- 会影响到巅峰记牌器的截图，最好保持与 Flash 网页差不多大小\n" +
                "\n" +
                "## 变速\n" +
                "- 登录器启动时开启一次，不支持在运行时调整\n" +
                "- 有时没开启成功，看战斗倒计时不对劲，就在菜单栏手动开一下\n" +
                "- 从 H5 切换回 Flash 也可能会失效\n" +
                "\n" +
                "## Flash 封包\n" +
                "- 勾选后，登录器启动时会打开另一个窗口，可以查看和发送封包\n" +
                "- 解析封包需要消耗额外的性能，平时尽量关着它\n" +
                "\n" +
                "# 致谢\n" +
                "## 明烛天南-w-（b站 UID：470857686）\n" +
                "- 登录器的 Flash 端长时间不刷新，会出现将封包断开发送的情况，影响到登录器对封包的解析和发送；当前的解决方式就是这位好兄弟想出来的\n" +
                "- 探索出隐藏 Flash 端对战界面的两种方法（另外一种比现在用的效果好一点，但是要修改战斗界面的 swf，不得不紧跟着官方进行更新，我就没用那种方法）\n"
                ;
        }
    }
}
