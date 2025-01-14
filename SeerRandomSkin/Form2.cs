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
                "- 全屏快捷键 F11、刷新 F5\n" +
                "- 登录器所在目录下的 cache 文件夹保存了浏览数据，请勿转发给他人；删掉的话类似清理缓存的效果（一般不需要清理）\n" +
                "\n" +
                "# 配置\n" +
                "手动点击右下角保存按钮，重新打开登录器才能生效\n\n" +
                "## 随机皮肤相关\n" +
                "- 只在 Flash 端，对 1000 序号及以后的精灵生效\n" +
                "- 默认的皮肤列表，动画大多比较流畅，可以根据你的喜好修改（随机选出的皮肤 id 在开发者工具的 Console 中显示）\n" +
                "- 皮肤黑名单 在[更新皮肤数据]时生效；更新是从 H5 端的一个 json 文件中获取所有[最新]皮肤，其中可能包含无法访问（导致战斗界面加载进度条停止）、缺少攻击动画的皮肤（出招时不播放动画，后续无法选技能），难以自动筛选，请自行添加到黑名单中\n" +
                "- 对皮肤序号范围的限制也是在更新皮肤数据时生效\n" +
                "- 可以单独设置某些精灵不随机换肤\n\n" +
                "### 关于皮肤动画的流畅程度问题\n" +
                "- 很多皮肤的动画播放起来会有卡顿的感觉，也被称为变速失效\n" +
                "- 缓解方式：\n" +
                "  1. 从随机皮肤列表删掉，或者指定皮肤替换（有可能只是对战其中一方的皮肤导致的卡顿，建议确认一下是哪边的问题）\n" +
                "  2. 地图上人多的话也会导致对战动画卡顿（哪怕是开了屏蔽其他赛尔），换个地图试试\n" +
                "  3. 忍耐一下（皮肤太好看，舍不得删）\n" +
                "\n" +
                "## 自定义窗口尺寸\n" +
                "- 与网页缩放搭配使用\n" +
                "- 会影响到巅峰记牌器的截图（截取窗口右半部分），最好调整到窗口边缘与 Flash 网页贴合，无白边\n" +
                "\n" +
                "## 变速\n" +
                "- 登录器启动时开启一次，可以设置是否自动打开调整倍速的窗口，不打开就一直保持同一个速度\n" +
                "- 有时没开启成功，看战斗倒计时没加速，就在菜单栏手动开一下\n" +
                "- 从 H5 切换回 Flash 也可能会失效\n" +
                "\n" +
                "## Flash 封包\n" +
                "- 勾选后，登录器启动时会打开另一个窗口，可以查看和发送封包\n" +
                "- 解析封包需要消耗额外的性能，不需要的时候请关闭\n" +
                "\n" +
                "# Flash 逛地图\n" +
                "  很多地图是专门放剧情的，无论是否完成过对应的任务，进去之后都会重新走流程，直接刷新就好\n" +
                "\n" +
                "# 致谢\n" +
                "## 梦开始的地方\n" +
                "- https://www.52pojie.cn/thread-1468888-1-1.html\n" +
                "- https://github.com/iyzyi/SeerPacket\n\n" +
                "## b站认识的小伙伴：明烛天南-w-\n" +
                "- 登录器的 Flash 端长时间不刷新，会出现将封包断开发送的情况，影响到登录器对封包的解析和发送；当前的解决方式就是这位好兄弟想出来的\n" +
                "- 探索出隐藏 Flash 端对战界面的两种方法（目前使用的方法，在每次登录后，如果显示过对战界面，就无法再隐藏；另一种方法可以随意切换，但是要修改战斗界面的 swf，不得不紧跟着官方进行更新，我就没用那种方法）\n"
                ;
        }
    }
}
