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
   import com.robot.core.info.fightInfo.attack.UseSkillInfo;
   import com.robot.core.info.fightInfo.attack.AttackValue;
   import com.robot.petFightModule_201308.view.TimerManager;
   
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
               PetManager.cureAllFree();
            }
            SocketConnection.removeCmdListener(CommandID.NOTE_USE_SKILL,SocketConnection.WxOnUseSkill);
         };
         SocketConnection.addCmdListener(CommandID.FIGHT_OVER,SocketConnection.WxOnFightEnd);

         // �Զ�����
         SocketConnection.WxIsAutoUseSkill = false;
         SocketConnection.WxNoteReadyToFight = function() : void
         {
            if (SocketConnection.WxIsAutoUseSkill)
            {
               SocketConnection.addCmdListener(CommandID.NOTE_USE_SKILL,SocketConnection.WxOnUseSkill);
            }
         };
         SocketConnection.addCmdListener(CommandID.NOTE_READY_TO_FIGHT,SocketConnection.WxNoteReadyToFight);
         SocketConnection.WxOnUseSkill = function(param1:SocketEvent) : void
         {
            var _loc2_:UseSkillInfo = param1.data as UseSkillInfo;
            var mySkillInfo:AttackValue;
            if (_loc2_.secondAttackInfo.userID != 0)
            {
               mySkillInfo = _loc2_.secondAttackInfo;
               if (_loc2_.firstAttackInfo.remainHP == 0)
               {
                  return; // �����ѱ�����
               }
            }
            else
            {
               mySkillInfo = _loc2_.firstAttackInfo;
               if (_loc2_.secondAttackInfo.remainHP == 0)
               {
                  return; // �����ѱ�����
               }
            }
            // ʹ�ü���
            // ���ﲻ���Զ��� pp����Ϊ ������� �� ��ɭ���� ���ܲ���Ҫ�� pp ����ʵ������д
            if (mySkillInfo.remainHP != 0)
            {
               SocketConnection.send(CommandID.USE_SKILL,mySkillInfo.skillID);
               TimerManager.wait(); // �ٷ��Ĵ������У���֪��������ʲô������
            }
         };
      }
   }
}
