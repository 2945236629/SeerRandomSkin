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
      }
   }
}
