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

         // �ٶ�С����
         NpcDialog.show(5766,["���С������������ SeerRandomSkin С���֣���Ҫʲô������"],["���̻�","�Զ�����","�Զ�����","����֮��,�һ�ǵ����ǵ�Լ����"],[function():void
         {
            SocketConnection.sendWithCallback(CommandID.LIST_MAP_PLAYER,function(param1:SocketEvent):void
            {
               var len:uint;
               var i:int;
               var userInfo:UserInfo = null;
               var byteArray:ByteArray = param1.data as ByteArray;
               byteArray.position = 0;
               len = byteArray.readUnsignedInt();
               i = 0;
               while(i < len)
               {
                  userInfo = new UserInfo();
                  UserInfo.setForPeoleInfo(userInfo,byteArray);
                  if(userInfo.fireBuff == 5)
                  {
                     SocketConnection.send(CommandID.FIRE_ACT_COPY,userInfo.userID);
                     // setTimeout(function():void
                     // {
                     //    Alarm.show("������ܿ�ʧЧ��Ŷ");
                     // },600000 * 2);
                     break;
                  }
                  if(userInfo.fireBuff == 6)
                  {
                     SocketConnection.send(CommandID.FIRE_ACT_COPY,userInfo.userID);
                     // setTimeout(function():void
                     // {
                     //    Alarm.show("������ܿ�ʧЧ��Ŷ");
                     // },600000 * 2 * 3);
                     break;
                  }
                  i++;
               }
            });
         },function():void
         {
            SocketConnection.WxIsAutoCure = !SocketConnection.WxIsAutoCure;
            Alarm.show(SocketConnection.WxIsAutoCure ? "�����Զ�����" : "�ر��Զ�����");
         },function():void
         {
            SocketConnection.WxIsAutoUseSkill = !SocketConnection.WxIsAutoUseSkill;
            Alarm.show(SocketConnection.WxIsAutoUseSkill ? "��ʼ�Զ�����" : "ֹͣ�Զ�����");
         }
         ],false,null,true);
      }
   }
}
