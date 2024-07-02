package
{
   import com.robot.core.CommandID;
   import com.robot.core.info.UserInfo;
   import com.robot.core.manager.PetManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.npc.NpcDialog;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.MovieClip;
   import flash.utils.ByteArray;
   import flash.utils.setTimeout;
   import org.taomee.events.SocketEvent;
   import flash.external.ExternalInterface;
   import com.robot.core.manager.MainManager;
   import com.robot.core.info.fightInfo.attack.UseSkillInfo;
   import com.robot.core.info.fightInfo.attack.AttackValue;
   import com.robot.petFightModule_201308.view.TimerManager;
   import com.robot.core.info.fightInfo.ChangePetInfo;
   import com.robot.core.manager.SystemTimerManager;
   
   [Embed(source="/_assets/assets.swf", symbol="item")]
   public dynamic class item extends MovieClip
   {
       
      
      public function item()
      {
         super();

         if (SocketConnection.WxScreenShot != null)
         {
            return;
         }

         // �ص��
         SocketConnection.send(41162,0);
         // �۷������
         SocketConnection.WxScreenShot = function() : void
         {
            ExternalInterface.call("seerRandomSkinObj.screenShot");
         };
         SocketConnection.addCmdListener(45144,SocketConnection.WxScreenShot);

         // �Զ�����
         SocketConnection.WxIsAutoCure = true;
         SocketConnection.WxAutoCureSwitch = function():void
         {
            SocketConnection.WxIsAutoCure = !SocketConnection.WxIsAutoCure;
            Alarm.show(SocketConnection.WxIsAutoCure ? "�����Զ�����" : "�ر��Զ�����");
         };
         ExternalInterface.addCallback("WxAutoCureSwitch",SocketConnection.WxAutoCureSwitch);
         SocketConnection.WxOnFightEnd = function() : void
         {
            if (SocketConnection.WxIsAutoCure)
            {
               PetManager.cureAll(false,false);
            }
         };
         SocketConnection.addCmdListener(CommandID.FIGHT_OVER,SocketConnection.WxOnFightEnd);

         // �Զ�����
         SocketConnection.WxIsAutoUseSkill = false;
         SocketConnection.WxAutoUseSkillStart = function():void
         {
            SocketConnection.WxIsAutoUseSkill = true;
         };
         SocketConnection.WxAutoUseSkillEnd = function():void
         {
            SocketConnection.WxIsAutoUseSkill = false;
         };
         ExternalInterface.addCallback("WxAutoUseSkillStart",SocketConnection.WxAutoUseSkillStart);
         ExternalInterface.addCallback("WxAutoUseSkillEnd",SocketConnection.WxAutoUseSkillEnd);
         // ����ս��
         SocketConnection.WxOnReadyToFight = function():void
         {
            SocketConnection.WxFightRound = 0;
         };
         SocketConnection.addCmdListener(CommandID.NOTE_READY_TO_FIGHT,SocketConnection.WxOnReadyToFight);
         // ʹ�ü���
         SocketConnection.WxOnUseSkill = function(param1:SocketEvent) : void
         {
            var mySkillInfo:AttackValue;
            var enemySkillInfo:AttackValue;
            var _loc2_:UseSkillInfo = param1.data as UseSkillInfo;
            if (_loc2_.firstAttackInfo.userID == MainManager.actorInfo.userID)
            {
               mySkillInfo = _loc2_.firstAttackInfo;
               enemySkillInfo = _loc2_.secondAttackInfo;
            }
            else
            {
               mySkillInfo = _loc2_.secondAttackInfo;
               enemySkillInfo = _loc2_.firstAttackInfo;
            }
            ExternalInterface.call("seerRandomSkinObj.showFightInfo",++SocketConnection.WxFightRound,enemySkillInfo.remainHP * 100 / enemySkillInfo.maxHp);
            if (enemySkillInfo.remainHP == 0 || !SocketConnection.WxIsAutoUseSkill)
            {
                return; // �����ѱ�����
            }
            // ʹ�ü���
            // ���ﲻ���Զ��� pp����Ϊ ������� �� ��ɭ���� ���ܲ���Ҫ�� pp ����ʵ������д
            if (mySkillInfo.remainHP != 0)
            {
               SocketConnection.send(CommandID.USE_SKILL,mySkillInfo.skillID);
               TimerManager.wait(); // �ٷ��Ĵ������У���֪��������ʲô������
            }
            else
            {
                // �л�����
                // changehps �������˵�ǰ�ڳ�������ģ����г�ս����
                for (var i:int = 0; i < mySkillInfo.changehps.length; i++)
                {
                    if (mySkillInfo.changehps[i].hp > 0)
                    {
                        SocketConnection.send(CommandID.CHANGE_PET,mySkillInfo.changehps[i].id);
                        return;
                    }
                }
            }
         };
         SocketConnection.addCmdListener(CommandID.NOTE_USE_SKILL,SocketConnection.WxOnUseSkill);
         // �л�����
         SocketConnection.WxOnChangePet = function(param1:SocketEvent):void
        {
            if (!SocketConnection.WxIsAutoUseSkill)
            {
                return;
            }
            var _loc2_:ChangePetInfo = param1.data as ChangePetInfo;
            // Ŀǰֻ����ȫ�������л�������������л������ʹ��0����
            if (_loc2_.userID == MainManager.actorInfo.userID)
            {
                SocketConnection.send(CommandID.USE_SKILL,0);
            }
        };
         SocketConnection.addCmdListener(CommandID.CHANGE_PET,SocketConnection.WxOnChangePet);

         // ѹѪ��ָ���������
         SocketConnection.WxCurePet20HP = function():void
         {
            SocketConnection.send(CommandID.ITEM_BUY,300011,6);
            SocketConnection.send(CommandID.ITEM_BUY,300017,6);
            var bag:Array = PetManager.getBagMap();
            for (var i:int = 0; i < bag.length; i++)
            {
                SocketConnection.send(CommandID.USE_PET_ITEM_OUT_OF_FIGHT,bag[i].catchTime,300011);
                SocketConnection.send(CommandID.USE_PET_ITEM_OUT_OF_FIGHT,bag[i].catchTime,300017);
            }
         };
         // ѹѪ
         SocketConnection.WxLowHPFightOver = function():void
         {
            SocketConnection.removeCmdListener(CommandID.FIGHT_OVER,SocketConnection.WxLowHPFightOver);
            SocketConnection.WxCurePet20HP();
            SocketConnection.WxIsAutoUseSkill = false;
            SocketConnection.WxIsAutoCure = true;
         };
         SocketConnection.WxLowHP = function():void
         {
            SocketConnection.addCmdListener(CommandID.FIGHT_OVER,SocketConnection.WxLowHPFightOver);
            SocketConnection.WxIsAutoUseSkill = true;
            SocketConnection.WxIsAutoCure = false;
            SocketConnection.send(41129, (SystemTimerManager.sysBJDate.hours < 12 || SystemTimerManager.sysBJDate.hours >= 15) ? 8692 : 8694);
            setTimeout(function():void
            {
               SocketConnection.send(CommandID.READY_TO_FIGHT);
               setTimeout(function():void
                {
                    SocketConnection.send(CommandID.USE_SKILL,0);
                },500);
            },500);
         };
         ExternalInterface.addCallback("WxLowHP",SocketConnection.WxLowHP);
      }
   }
}
