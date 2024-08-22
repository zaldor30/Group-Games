local _, ns = ... -- Namespace (myaddon, namespace)
ns = {}

ICON_PATH = 'Interface\\AddOns\\GroupGames\\Images\\'
GG = LibStub('AceAddon-3.0'):NewAddon('GroupGames', 'AceEvent-3.0', 'AceComm-3.0')

GG.author  = C_AddOns.GetAddOnMetadata('GroupGames', 'Author')
GG.version = C_AddOns.GetAddOnMetadata('GroupGames', 'Version')

GG.debug = false
GG.isPreRelease = true
GG.preReleaseType = 'Pre-Alpha'
GG.versionOut = '(v'..GG.version..(GG.isPreRelease and ' '..GG.preReleaseType or '')..')'

-- Colors
DEFAULT_CHAT_COLOR = 'FF3EB9D8'

-- Icons
APP_ICON = ICON_PATH..'GG_Icon'
HOME_ICON = ICON_PATH..'GG_Back'
SETTINGS_ICON = ICON_PATH..'GG_Settings'
FRAME_LOCKED_ICON = ICON_PATH..'GG_Locked'
FRAME_UNLOCKED_ICON = ICON_PATH..'GG_Unlocked'

-- Highlgiht Images
BLUE_OUTLINE_HIGHLIGHT = 'UI-CharacterCreate-LargeButton-Blue-Highlight'
AH_BLUE_HIGHLIGHT = 'auctionhouse-nav-button-highlight'
RED_HIGHLIGHT = '128-GoldRedButton-Highlight'
BLUE_HIGHLIGHT = 'bags-glow-heirloom'
BLUE_LONG_HIGHLIGHT = 'communitiesfinder_card_highlight'

-- Frame Stratas
BACKGROUND_STRATA = 'BACKGROUND'
LOW_STRATA = 'LOW'
MEDIUM_STRATA = 'MEDIUM'
HIGH_STRATA = 'HIGH'
DIALOG_STRATA = 'DIALOG'
TOOLTIP_STRATA = 'TOOLTIP'
DEFAULT_STRATA = BACKGROUND_STRATA

-- Backdrop Templates
DEFAULT_BORDER = 'Interface\\Tooltips\\UI-Tooltip-Border'
BLANK_BACKGROUND = 'Interface\\Buttons\\WHITE8x8'
DIALOGUE_BACKGROUND = 'Interface\\DialogFrame\\UI-DialogBox-Background'
function BackdropTemplate(bgImage, edgeImage, tile, tileSize, edgeSize, insets)
	tile = tile == 'NO_TILE' and false or true

	return {
		bgFile = bgImage or DIALOGUE_BACKGROUND,
		edgeFile = edgeImage or DEFAULT_BORDER,
		tile = true,
		tileSize = tileSize or 16,
		edgeSize = edgeSize or 16,
		insets = insets or { left = 3, right = 3, top = 3, bottom = 3 }
	}
end