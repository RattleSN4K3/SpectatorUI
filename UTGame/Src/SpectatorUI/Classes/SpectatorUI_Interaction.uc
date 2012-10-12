class SpectatorUI_Interaction extends Interaction within PlayerController;

struct SpectatorUI_SpeedBind {
    var name Key;
    var int Value;
};
var array<SpectatorUI_SpeedBind> SpeedBinds;
var int Speeds[10];

simulated static function SpectatorUI_Interaction MaybeSpawnFor(PlayerController PC) {
    local Interaction Interaction;
    local SpectatorUI_Interaction SUI_Interaction;

    foreach PC.Interactions(Interaction) {
        if (SpectatorUI_Interaction(Interaction) != None) {
            return SpectatorUI_Interaction(Interaction);
        }
    }
    
    SUI_Interaction = new(PC) default.class;
    // have to insert it first so it could intercept
    // bound keys
    PC.Interactions.InsertItem(0, SUI_Interaction);
    return SUI_Interaction;
}

static final function bool SameDirection(vector a, vector b) {
    return a dot b >= 0;
}

simulated function bool ShouldRender() {
    return IsSpectating();
}

simulated event PostRender(Canvas Canvas) {
    local vector Loc, Dir;
    local rotator Rot;
    local UTHUD HUD;
    local Actor A;
    
    super.PostRender(Canvas);

    HUD = UTHUD(myHUD);
    if (HUD == None || !ShouldRender()) return;

    Canvas.Font = HUD.GetFontSizeIndex(0);
    
    GetPlayerViewPoint(Loc, Rot);
    Dir = vector(Rot);

    foreach HUD.PostRenderedActors(A) {
        if (A == None) continue;
        if (!SameDirection(Dir, A.Location - Loc)) continue;

        if (UTPawn(A) != None) {
            UTPawn_PostRenderFor(UTPawn(A), Outer, Canvas, Loc, Dir);
        } else if (UTVehicle(A) != None) {
            UTVehicle_PostRenderFor(UTVehicle(A), Outer, Canvas, Loc, Dir);
        }
    }
}

simulated static function UTPawn_PostRenderFor(UTPawn P, PlayerController PC, Canvas Canvas, vector Loc, vector Dir) {
    local bool bPostRenderOtherTeam;
    local float TeamBeaconMaxDist;
    local float TeamBeaconPlayerInfoMaxDist;

    bPostRenderOtherTeam = P.bPostRenderOtherTeam;
    TeamBeaconMaxDist = P.TeamBeaconMaxDist;
    TeamBeaconPlayerInfoMaxDist = P.TeamBeaconPlayerInfoMaxDist;

    P.bPostRenderOtherTeam = true;
    P.TeamBeaconMaxDist *= 3;
    P.TeamBeaconPlayerInfoMaxDist *= 3;

    P.NativePostRenderFor(PC, Canvas, Loc, Dir);

    P.bPostRenderOtherTeam = bPostRenderOtherTeam;
    P.TeamBeaconMaxDist = TeamBeaconMaxDist;
    P.TeamBeaconPlayerInfoMaxDist = TeamBeaconPlayerInfoMaxDist;
}

simulated static function UTVehicle_PostRenderFor(UTVehicle V, PlayerController PC, Canvas Canvas, vector Loc, vector Dir) {
    local bool bPostRenderOtherTeam;
    local float TeamBeaconMaxDist;
    local float TeamBeaconPlayerInfoMaxDist;

    bPostRenderOtherTeam = V.bPostRenderOtherTeam;
    TeamBeaconMaxDist = V.TeamBeaconMaxDist;
    TeamBeaconPlayerInfoMaxDist = V.TeamBeaconPlayerInfoMaxDist;

    V.bPostRenderOtherTeam = true;
    V.TeamBeaconMaxDist *= 3;
    V.TeamBeaconPlayerInfoMaxDist *= 3;

    V.NativePostRenderFor(PC, Canvas, Loc, Dir);

    V.bPostRenderOtherTeam = bPostRenderOtherTeam;
    V.TeamBeaconMaxDist = TeamBeaconMaxDist;
    V.TeamBeaconPlayerInfoMaxDist = TeamBeaconPlayerInfoMaxDist;
}

exec function SpectatorUI_SetSpeed(byte x)
{
    bRun = x;
}

exec function SpectatorUI_AddSpeed(int x)
{
    bRun = clamp(bRun + x, 0, 255);
}

exec function SpectatorUI_MultiplySpeed(int x)
{
    bRun = clamp((1 + bRun << x) - 1, 0, 255);
}

exec function SpectatorUI_DivideSpeed(int x)
{
    bRun = clamp((1 + bRun >> x) - 1, 0, 255);
}

function bool HandleInputKey(int ControllerId, name Key, EInputEvent EventType, float AmountDepressed, bool bGamepad)
{
    local int i;
    if (ShouldRender() && LocalPlayer(Player) != None && LocalPlayer(Player).ControllerId == ControllerId) {
        if (EventType ==  IE_Released) {
            i = SpeedBinds.Find('Key', Key);
            if (i != INDEX_NONE) {
                bRun = Speeds[SpeedBinds[i].Value];
            }
        }
    }
    return false;
}

defaultproperties
{
    OnReceivedNativeInputKey=HandleInputKey

    SpeedBinds.Add((Key=one,Value=0))
    SpeedBinds.Add((Key=two,Value=1))
    SpeedBinds.Add((Key=three,Value=2))
    SpeedBinds.Add((Key=four,Value=3))
    SpeedBinds.Add((Key=five,Value=4))
    SpeedBinds.Add((Key=six,Value=5))
    SpeedBinds.Add((Key=seven,Value=6))
    SpeedBinds.Add((Key=eight,Value=7))
    SpeedBinds.Add((Key=nine,Value=8))
    SpeedBinds.Add((Key=zero,Value=9))

    SpeedBinds.Add((Key=NumPadone,Value=1))
    SpeedBinds.Add((Key=NumPadtwo,Value=2))
    SpeedBinds.Add((Key=NumPadthree,Value=3))
    SpeedBinds.Add((Key=NumPadfour,Value=4))
    SpeedBinds.Add((Key=NumPadfive,Value=5))
    SpeedBinds.Add((Key=NumPadsix,Value=6))
    SpeedBinds.Add((Key=NumPadseven,Value=7))
    SpeedBinds.Add((Key=NumPadeight,Value=8))
    SpeedBinds.Add((Key=NumPadnine,Value=9))
    SpeedBinds.Add((Key=NumPadzero,Value=0))

    Speeds[0] = 0
    Speeds[1] = 1
    Speeds[2] = 2
    Speeds[3] = 4
    Speeds[4] = 8
    Speeds[5] = 16
    Speeds[6] = 32
    Speeds[7] = 64
    Speeds[8] = 128
    Speeds[9] = 255
}
