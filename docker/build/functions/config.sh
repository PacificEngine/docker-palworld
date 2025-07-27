#!/bin/bash
source /build/functions/variables.sh
source /build/functions/log.sh
source /server/regex.sh
source /server/properties.sh

setToDefaultConfig() {
  echo '''
[/Script/Pal.PalGameWorldSettings]
OptionSettings=(Difficulty=None,RandomizerType=None,RandomizerSeed="",bIsRandomizerPalLevelRandom=False,DayTimeSpeedRate=1.000000,NightTimeSpeedRate=1.000000,ExpRate=1.000000,PalCaptureRate=1.000000,PalSpawnNumRate=1.000000,PalDamageRateAttack=1.000000,PalDamageRateDefense=1.000000,PlayerDamageRateAttack=1.000000,PlayerDamageRateDefense=1.000000,PlayerStomachDecreaceRate=1.000000,PlayerStaminaDecreaceRate=1.000000,PlayerAutoHPRegeneRate=1.000000,PlayerAutoHpRegeneRateInSleep=1.000000,PalStomachDecreaceRate=1.000000,PalStaminaDecreaceRate=1.000000,PalAutoHPRegeneRate=1.000000,PalAutoHpRegeneRateInSleep=1.000000,BuildObjectHpRate=1.000000,BuildObjectDamageRate=1.000000,BuildObjectDeteriorationDamageRate=1.000000,CollectionDropRate=1.000000,CollectionObjectHpRate=1.000000,CollectionObjectRespawnSpeedRate=1.000000,EnemyDropItemRate=1.000000,DeathPenalty=All,bEnablePlayerToPlayerDamage=False,bEnableFriendlyFire=False,bEnableInvaderEnemy=True,bActiveUNKO=False,bEnableAimAssistPad=True,bEnableAimAssistKeyboard=False,DropItemMaxNum=3000,DropItemMaxNum_UNKO=100,BaseCampMaxNum=128,BaseCampWorkerMaxNum=20,DropItemAliveMaxHours=1.000000,bAutoResetGuildNoOnlinePlayers=False,AutoResetGuildTimeNoOnlinePlayers=10000.000000,GuildPlayerMaxNum=20,BaseCampMaxNumInGuild=8,PalEggDefaultHatchingTime=72.000000,WorkSpeedRate=1.000000,AutoSaveSpan=30.000000,bIsMultiplay=False,bIsPvP=False,bHardcore=False,bPalLost=False,bCharacterRecreateInHardcore=False,bCanPickupOtherGuildDeathPenaltyDrop=False,bEnableNonLoginPenalty=True,bEnableFastTravel=True,bIsStartLocationSelectByMap=True,bExistPlayerAfterLogout=False,bEnableDefenseOtherGuildPlayer=False,bInvisibleOtherGuildBaseCampAreaFX=False,bBuildAreaLimit=False,ItemWeightRate=1.000000,CoopPlayerMaxNum=8,ServerPlayerMaxNum=32,ServerName="",ServerDescription="",AdminPassword="",ServerPassword="",PublicPort=8211,PublicIP="",RCONEnabled=False,RCONPort=25575,Region="",bUseAuth=True,BanListURL="https://api.palworldgame.com/api/banlist.txt",RESTAPIEnabled=True,RESTAPIPort=8080,bShowPlayerList=False,ChatPostLimitPerMinute=30,CrossplayPlatforms=(Steam,Xbox,PS5,Mac),bIsUseBackupSaveData=True,LogFormatType=Text,SupplyDropSpan=180,EnablePredatorBossPal=True,MaxBuildingLimitNum=0,ServerReplicatePawnCullDistance=15000.000000,bAllowGlobalPalboxExport=True,bAllowGlobalPalboxImport=False,EquipmentDurabilityDamageRate=1.000000,ItemContainerForceMarkDirtyInterval=1.000000)
  ''' > "${CONFIG_DIRECTORY}/PalWorldSettings.ini"
}

hasValue() {
  local currentKey=''
  currentKey="$(cat "${CONFIG_DIRECTORY}/PalWorldSettings.ini" | regex --find "(${1})=" --group 1 --trim)"
  if [[ -z "${currentKey}" ]]; then
    echo 'false'
  else
    echo 'true'
  fi
}

getConfig() {
  cat "${CONFIG_DIRECTORY}/PalWorldSettings.ini" | regex --find "${1}=([^,]*)" --group 1 --trim
}

setConfig() {
  sed -i "s/${1}=[^,]*/${1}=${2}/g" "${CONFIG_DIRECTORY}/PalWorldSettings.ini"
}

updateConfig() {
  if [[ "$(hasValue "${1}")" == 'false' ]]; then
    log "Unable to set value for '${1}'"
  elif [[ "$(getConfig "${1}")" != "${2}" ]]; then
    log "Updating value for '${1}'"
    setConfig "${1}" "${2}"
  fi
}

updateConfigSettings() {
  local key=''
  local value=''
  local updates="RESTAPIEnabled=True,RESTAPIPort=${PORT_API},${CONFIG_UPDATES}"
  local OLD_IFS="${IFS}"

  if [[ "$(hasValue "Difficulty")" == 'false' ]]; then
    log "No config file found, creating one"
    setToDefaultConfig
  fi

  IFS=','
  for config in `echo "${updates}"`; do
    key=${config%=*}
    value=${config#*=}
    if [[ -n "${key}" ]]; then
      updateConfig "${key}" "${value}"
    fi
  done
  IFS="${OLD_IFS}"
}