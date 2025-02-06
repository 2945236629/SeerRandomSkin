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
   import flash.utils.JSON;
   import org.taomee.events.SocketEvent;
   import flash.external.ExternalInterface;
   import com.robot.core.manager.MainManager;
   import com.robot.core.info.fightInfo.attack.UseSkillInfo;
   import com.robot.core.info.fightInfo.attack.AttackValue;
   import com.robot.petFightModule_201308.view.TimerManager;
   import com.robot.core.info.fightInfo.ChangePetInfo;
   import com.robot.core.manager.SystemTimerManager;
   import com.robot.core.info.fightInfo.FightStartInfo;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.config.xml.SkillXMLInfo;
   import com.robot.app.task.petstory.util.KTool;
   import com.robot.core.info.fightInfo.NoteReadyToFightInfo;
   import com.robot.core.info.fightInfo.FighterUserInfos;
   import com.robot.core.info.fightInfo.FightStartInfo;
   import com.robot.core.info.fightInfo.attack.FightOverInfo;
   import com.robot.app.toolBar.ToolBarController;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.ModuleManager;
   import com.robot.app2.control.PeakJihad2023Controller;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.MapXMLInfo;
   import com.robot.core.info.pet.PetStorage2015PetInfo;
   import com.codecatalyst.promise.Promise;
   import com.robot.core.behavior.ChangeClothBehavior;
   import com.robot.core.manager.UserManager;
   import com.robot.core.info.clothInfo.PeopleItemInfo;
   import com.robot.core.info.UserInfo;
   import com.robot.core.ui.alert.SimpleAlarm;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.manager.ItemManager;
   import com.robot.app.fight.FightManager;
   
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

         // xml
         ExternalInterface.addCallback("WxGetItemNameByID", function(itemID:uint):String
         {
            return ItemXMLInfo.getName(itemID);
         }
         );
         ExternalInterface.addCallback("WxGetAllCloth", function():Array
         {
            return ItemXMLInfo.getAllCloth();
         }
         );
         ExternalInterface.addCallback("WxGetPetNameByID", function(petID:uint):String
         {
            return PetXMLInfo.getName(petID);
         }
         );
         ExternalInterface.addCallback("WxGetSkillNameByID", function(skillID:uint):String
         {
            return SkillXMLInfo.getName(skillID);
         }
         );

         // ��ȡ����������Ϣ
        ExternalInterface.addCallback("WxGetBagPetInfos",
            function():Array
            {
                return PetManager.allInfos;
            }
        );

         // ��ͼ �� �
         ExternalInterface.addCallback("WxChangeMap",MapManager.changeMap);
         ExternalInterface.addCallback("WxChangeMapRandom",function():uint
         {
            var mapList:Array = MapXMLInfo.getIDList();
            var id:uint = mapList[Math.round(Math.random() * mapList.length)];
            MapManager.changeMap(id);
            return id;
         });
         ExternalInterface.addCallback("WxShowAppModule",ModuleManager.showAppModule);

         // ���������û�
         ToolBarController.showOrHideAllUser(false);

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
         SocketConnection.WxAutoCureStart = function():void
         {
            SocketConnection.WxIsAutoCure = true;
         };
         SocketConnection.WxAutoCureStop = function():void
         {
            SocketConnection.WxIsAutoCure = false;
         };
         ExternalInterface.addCallback("WxAutoCureStart",SocketConnection.WxAutoCureStart);
         ExternalInterface.addCallback("WxAutoCureStop",SocketConnection.WxAutoCureStop);
         SocketConnection.WxCurePetAll = function():void
         {
            var bagBoth:Array = PetManager.getBagMap(true);
            for (var i:int = 0; i < bagBoth.length; ++i)
            {
                SocketConnection.send(CommandID.PET_ONE_CURE,bagBoth[i].catchTime);
            }
         };
         ExternalInterface.addCallback("WxCurePetAll",SocketConnection.WxCurePetAll);
         SocketConnection.WxOnFightEnd = function(event:SocketEvent) : void
         {
            if (SocketConnection.WxIsAutoCure)
            {
                SocketConnection.WxCurePetAll();
            }
            var fightOverInfo:FightOverInfo = event.data as FightOverInfo;
            ExternalInterface.call("WxFightHandler.OnFightOver",fightOverInfo);
         };
         SocketConnection.addCmdListener(CommandID.FIGHT_OVER,SocketConnection.WxOnFightEnd);

         // ʹ�ü���
         SocketConnection.WxUseSkill = function(skillID:uint):void
         {
            SocketConnection.send(CommandID.USE_SKILL,skillID);
         };
         ExternalInterface.addCallback("WxUseSkill",SocketConnection.WxUseSkill);
         // �л�����
         SocketConnection.WxChangePet = function(petCatchTime:uint):void
         {
            for each(var pet in SocketConnection.WxFightingPets) {
                if (pet.catchTime == SocketConnection.WxFightingPetCatchTime) {
                    // ��������л�
                    if (pet.hp > 0) { SocketConnection.WxIsPositiveChangePet = true; break; }
                }
            }
            SocketConnection.send(CommandID.CHANGE_PET,petCatchTime);
         };
         ExternalInterface.addCallback("WxChangePet",SocketConnection.WxChangePet);
         ExternalInterface.addCallback("WxChangePetByID",function(ids:Array):void
         {
            if (ids.length == 0) {
                for each(var pet in SocketConnection.WxFightingPets) {
                    if (pet.hp > 0 && pet.catchTime != SocketConnection.WxFightingPetCatchTime) { SocketConnection.WxChangePet(pet.catchTime); break; }
                }
                return;
            }
            for each(var id:int in ids) {
                for each(var pet in SocketConnection.WxFightingPets) {
                    if (pet.hp > 0 && pet.catchTime != SocketConnection.WxFightingPetCatchTime && pet.id == id) { SocketConnection.WxChangePet(pet.catchTime); return; }
                }
            }
            for each(var pet in SocketConnection.WxFightingPets) {
                if (pet.hp > 0 && pet.catchTime != SocketConnection.WxFightingPetCatchTime) { SocketConnection.WxChangePet(pet.catchTime); break; }
            }
            ExternalInterface.call("console.log","δ�ҵ�ָ�� id �ľ���",ids);
         });
         // ʹ��ҩ��
         ExternalInterface.addCallback("WxUsePetItem", function(itemID:uint):void
         {
            SocketConnection.send(CommandID.USE_PET_ITEM,SocketConnection.WxFightingPetCatchTime,itemID,0);
         });
         ExternalInterface.addCallback("WxItemBuy", function(itemID:uint):void
         {
            SocketConnection.send(CommandID.ITEM_BUY,itemID,1);
         });

         // ��ȡս��ʱ�ڳ����� ID
         ExternalInterface.addCallback("WxGetFightingPetID", function():uint
         {
            return SocketConnection.WxFightingPetID;
         });
         ExternalInterface.addCallback("WxGetFightingPetCatchTime", function():uint
         {
            return SocketConnection.WxFightingPetCatchTime;
         });
         ExternalInterface.addCallback("WxGetFightingPets", function():Array
         {
            return SocketConnection.WxFightingPets;
         });

         // �Զ�����
         // ����ս��
         SocketConnection.addCmdListener(CommandID.NOTE_READY_TO_FIGHT,function(event:SocketEvent):void
         {
            var readyData:NoteReadyToFightInfo = event.data as NoteReadyToFightInfo;
            SocketConnection.WxFightingPets = []; // �����л����鹦��
            var skillIndex:uint = 0;
            for each(var petInfo:PetInfo in readyData.userInfos.myInfo.petInfoArr) {
                var pet:Object = new Object();
                pet.id = petInfo.id;
                pet.catchTime = petInfo.catchTime;
                pet.hp = petInfo.hp;
                pet.skillArray = [];
                for (var i:int = 0; i < Math.min(4,petInfo.skillNum); ++i, ++skillIndex) {
                    pet.skillArray.push(readyData.userInfos.allSkillID[skillIndex]);
                }
                pet.hideSKill = petInfo.hideSKill;
                SocketConnection.WxFightingPets.push(pet);
            }
            ExternalInterface.call("WxFightHandler.Utils.RoundReset");
            SocketConnection.WxIsPositiveChangePet = false;
         });
         // �׷�������Ϣ
         SocketConnection.addCmdListener(CommandID.NOTE_START_FIGHT,function(event:SocketEvent):void
         {
            var _loc2_:FightStartInfo = event.data as FightStartInfo;
            SocketConnection.WxFightingPetCatchTime = _loc2_.myInfo.catchTime;
            SocketConnection.WxFightingPetID = _loc2_.myInfo.petID;
            ExternalInterface.call("WxFightHandler.OnFirstRound",_loc2_);
         });
         // ʹ�ü���
         SocketConnection.addCmdListener(CommandID.NOTE_USE_SKILL, function(param1:SocketEvent) : void
         {
            var mySkillInfo:AttackValue;
            var enemySkillInfo:AttackValue;
            var _loc2_:UseSkillInfo = param1.data as UseSkillInfo;
            var isMeFirst:Boolean = true;
            if (_loc2_.firstAttackInfo.userID == MainManager.actorInfo.userID)
            {
               mySkillInfo = _loc2_.firstAttackInfo;
               enemySkillInfo = _loc2_.secondAttackInfo;
            }
            else
            {
               mySkillInfo = _loc2_.secondAttackInfo;
               enemySkillInfo = _loc2_.firstAttackInfo;
               isMeFirst = false;
            }

            for (var i:int = 0; i < SocketConnection.WxFightingPets.length; ++i) {
                if (SocketConnection.WxFightingPets[i].catchTime == SocketConnection.WxFightingPetCatchTime) {
                    SocketConnection.WxFightingPets[i].hp = mySkillInfo.remainHP;
                    break;
                }
            }
            for each(var pet in mySkillInfo.changehps) {
                for (var i:int = 0; i < SocketConnection.WxFightingPets.length; ++i) {
                    if (SocketConnection.WxFightingPets[i].catchTime == pet.id) {
                        SocketConnection.WxFightingPets[i].hp = pet.hp;
                        break;
                    }
                }
            }

            var hpPercent:Number = enemySkillInfo.maxHp == 0 ? 0 : enemySkillInfo.remainHP * 100 / enemySkillInfo.maxHp;
            ExternalInterface.call("WxFightHandler.Utils.ShowRound",hpPercent);
            if (enemySkillInfo.remainHP == 0)
            {
                var isEnemyAllDead:Boolean = true;
                for (var i:int = 0; i < enemySkillInfo.changehps.length; ++i)
                {
                    if (enemySkillInfo.changehps[i].hp > 0)
                    {
                        isEnemyAllDead = false; break;
                    }
                }
                if (isEnemyAllDead)
                {
                    return;
                }
            }

            ExternalInterface.call("WxFightHandler.OnUseSkill",mySkillInfo,enemySkillInfo,isMeFirst);
         });
         // �л�����
         SocketConnection.addCmdListener(CommandID.CHANGE_PET,function(param1:SocketEvent):void
        {
            var _loc2_:ChangePetInfo = param1.data as ChangePetInfo;
            // �����л�
            if (_loc2_.userID == MainManager.actorInfo.userID) {
                SocketConnection.WxFightingPetID = _loc2_.petID;
                SocketConnection.WxFightingPetCatchTime = _loc2_.catchTime;
                if (SocketConnection.WxIsPositiveChangePet)
                {
                    SocketConnection.WxIsPositiveChangePet = false;
                }
                else
                {
                    // �����л�����ܳ���
                    ExternalInterface.call("WxFightHandler.OnChangePet",_loc2_);
                }
            }
        });

         // ѹѪ��ָ���������
         SocketConnection.WxCurePet20HP = function():void
         {
            SocketConnection.send(CommandID.ITEM_BUY,300011,6);
            SocketConnection.send(CommandID.ITEM_BUY,300017,6);
            var bag:Array = PetManager.getBagMap();
            for each(var pet in bag)
            {
                SocketConnection.send(CommandID.USE_PET_ITEM_OUT_OF_FIGHT,pet.catchTime,300011);
                SocketConnection.send(CommandID.USE_PET_ITEM_OUT_OF_FIGHT,pet.catchTime,300017);
            }
         };
         ExternalInterface.addCallback("WxCurePet20HP",SocketConnection.WxCurePet20HP);
         // ѹѪ
         SocketConnection.WxLowHPFightOver = function():void
         {
            SocketConnection.removeCmdListener(CommandID.FIGHT_OVER,SocketConnection.WxLowHPFightOver);
            SocketConnection.WxAutoCureStart();
            SocketConnection.WxCurePet20HP();
         };
         SocketConnection.WxLowHP = function():void
         {
            SocketConnection.WxAutoCureStop();
            SocketConnection.send(41129, (SystemTimerManager.sysBJDate.hours < 12 || SystemTimerManager.sysBJDate.hours >= 15) ? 8692 : 8694);
            SocketConnection.addCmdListener(CommandID.FIGHT_OVER,SocketConnection.WxLowHPFightOver);
         };
         ExternalInterface.addCallback("WxLowHP",SocketConnection.WxLowHP);

         // ��ȡ�ֿ⾫��
         SocketConnection.WxGetStoragePets = function(allInfo:Array,startID:int = 1):void
         {
            SocketConnection.sendWithPromise(45543,[startID - 1,startID + 998]).then(function(e:SocketEvent):void
            {
                var b:ByteArray = e.data as ByteArray;
                var len:int = int(b.readUnsignedInt());
                for(var i:int = 0; i < len; i++)
                {
                   allInfo.push(new PetStorage2015PetInfo(b));
                }
                if(len == 1000)
                {
                   SocketConnection.WxGetStoragePets(allInfo,startID + 1000);
                }
                else
                {
                   ExternalInterface.call("WxFightHandler.Utils._as3Callback",allInfo);
                }
            });
         };
         ExternalInterface.addCallback("WxGetStoragePets", function():void
         {
            SocketConnection.WxGetStoragePets([]);
         }
         );
         // ����
        ExternalInterface.addCallback("WxGetBag1",
            function():Array
            {
                return PetManager.getBagMap();
            }
        );
        ExternalInterface.addCallback("WxGetBag2",
            function():Array
            {
                return PetManager.getSecondBagMap();
            }
        );
        ExternalInterface.addCallback("WxClearBag",function():void
        {
            var bagBoth:Array = PetManager.getBagMap(true);
            if (bagBoth.length > 0) {
                var promises:Array = new Array();
                for each(var pet in bagBoth) { promises.push(PetManager.bagToInStorage(pet.catchTime)); }
                Promise.all(promises).then(function():void { ExternalInterface.call("WxFightHandler.Utils._as3Callback"); });
            }
            else {
                ExternalInterface.call("WxFightHandler.Utils._as3Callback");
            }
        });
        ExternalInterface.addCallback("WxSetBag1",function(bag1:Array):void
        {
            if (bag1.length > 0) {
                var promises:Array = new Array();
                for each(var pet in bag1) { promises.push(PetManager.storageToInBag(pet)); }
                Promise.all(promises).then(function():void { PetManager.upDateByOnce(); ExternalInterface.call("WxFightHandler.Utils._as3Callback"); });
            }
            else {
                ExternalInterface.call("WxFightHandler.Utils._as3Callback");
            }
        });
        ExternalInterface.addCallback("WxSetBag2",function(bag2:Array):void
        {
            if (bag2.length > 0) {
                var promises:Array = new Array();
                for each(var pet in bag2) { promises.push(PetManager.storageToSecondBag(pet)); }
                Promise.all(promises).then(function():void { PetManager.upDateByOnce(); ExternalInterface.call("WxFightHandler.Utils._as3Callback"); });
            }
            else {
                ExternalInterface.call("WxFightHandler.Utils._as3Callback");
            }
        });
         ExternalInterface.addCallback("WxGetClothes", function():Array
         {
            var clothes:Array = MainManager.actorInfo.clothes;
            var result:Array = [];
            for each(var cloth in clothes)
            {
                result.push(cloth.id);
                result.push(cloth.level);
            }
            return result;
         }
         );
         ExternalInterface.addCallback("WxChangeCloth", function(clothes:Array):void
         {
            var clothArray:Array = [];
            for (var i:int = 0; i < clothes.length; i+=2)
            {
                clothArray.push(new PeopleItemInfo(clothes[i],clothes[i+1]));
            }
            MainManager.actorModel.execBehavior(new ChangeClothBehavior(clothArray));
         }
         );
         ExternalInterface.addCallback("WxGetTitle", function():uint
         {
            return MainManager.actorInfo.curTitle;
         }
         );
         ExternalInterface.addCallback("WxSetTitle", function(title:uint):void
         {
            if (MainManager.actorInfo.curTitle != title) {
            SocketConnection.sendWithCallback(CommandID.SETTITLE,function(param1:SocketEvent):void
            {
                var _loc2_:ByteArray = null;
                if(param1.data)
                {
                    _loc2_ = param1.data as ByteArray;
                    MainManager.actorInfo.curTitle = _loc2_.readUnsignedInt();
                }
                else
                {
                    MainManager.actorInfo.curTitle = 0;
                }
                MainManager.actorModel.refreshTitle(MainManager.actorInfo.curTitle);
            },title);
            }
            SimpleAlarm.show(title);
         }
         );

         ExternalInterface.addCallback("WxCopyFire", function(fireType:uint):uint
         {
            SocketConnection.sendWithCallback(CommandID.LIST_MAP_PLAYER,function(param1:SocketEvent):void
            {
                var byteArray:ByteArray = param1.data as ByteArray;
                var len:uint = byteArray.readUnsignedInt();
                for (var i:int = 0; i < len; ++i)
                {
                    var userInfo:UserInfo = new UserInfo();
                    UserInfo.setForPeoleInfo(userInfo,byteArray);
                    if (userInfo.fireBuff == fireType)
                    {
                        SocketConnection.send(CommandID.FIRE_ACT_COPY,userInfo.userID);
                        SimpleAlarm.show("���ɹ�");
                        return;
                    }
                }
                SimpleAlarm.show("���ʧ��");
            });
         }
         );

         // ��������
         ExternalInterface.addCallback("WxSend",SocketConnection.send);
         ExternalInterface.addCallback("WxSendWithCallback2", function(commandID:int, parameterArray:Array = null):void
         {
            SocketConnection.sendWithCallback2(commandID,
            function(event:SocketEvent):void
            {
                var data:ByteArray = event.data as ByteArray;
                var packet:Array = new Array();
                for (var i:int = 0; i < data.length; i++)
                {
                    packet.push(data.readUnsignedByte());
                }
                ExternalInterface.call("WxFightHandler.Utils._as3Callback",packet);
            }
            ,parameterArray);
         }
         );

         // ��ȡ��Ʒ����
         ExternalInterface.addCallback("WxGetItemNumByID", function(id:uint):int
         {
            return ItemManager.getNumByID(id);
         }
         );

         // ���ض�ս����
         ExternalInterface.addCallback("WxSetIsHidePetFight", function(hide:Boolean):void
         {
            FightManager.petFightClass = hide ? "PetFightDLL" : "PetFightDLL_201308";
         }
         );

         // �Զ����ͼ�ϵ�Ұ�������ս
         SocketConnection.WxOnOgreList = function(e:SocketEvent):void {
            var ba:ByteArray = e.data as ByteArray;
            ba.position = 0;
            for (var i:int = 0; i < 9; ++i) {
                if (ba.readUnsignedInt() == SocketConnection.WxWaitingForOrgeID) { FightManager.fightWithNpc(i); return; }
            }
         };
         ExternalInterface.addCallback("WxAutoFight", function(petID:uint):void
         {
            SocketConnection.removeCmdListener(CommandID.MAP_OGRE_LIST,SocketConnection.WxOnOgreList);
            SocketConnection.WxWaitingForOrgeID = petID;
            SocketConnection.addCmdListener(CommandID.MAP_OGRE_LIST,SocketConnection.WxOnOgreList);
         });

         // ��ʾ��Ϣ
         ExternalInterface.addCallback("WxSimpleAlarm",SimpleAlarm.show);
         ExternalInterface.addCallback("WxAlarm",function(msg:String):void { Alarm.show(msg); });

         // �� nono ���زֿ�
         setTimeout(function():void
         {
             SocketConnection.send(CommandID.NONO_FOLLOW_OR_HOOM,0);
         }, 1000);
      }
   }
}
