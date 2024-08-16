local _, ns = ... -- Namespace (myaddon, namespace)
ns = {}

ICON_PATH = 'Interface\\AddOns\\GroupGames\\Images\\'

GG = LibStub('AceAddon-3.0'):NewAddon('GroupGames', 'AceConsole-3.0', 'AceHook-3.0', 'AceComm-3.0')
GG.author  = C_AddOns.GetAddOnMetadata('GroupGames', 'Author')
GG.version = C_AddOns.GetAddOnMetadata('GroupGames', 'Version')
-- Icons
GG.icon = ICON_PATH..'GG_Icon.tga'
GG.locked = ICON_PATH..'GG_Locked'
GG.Unlocked = ICON_PATH..'GG_Unlocked'

-- Default Colors
GG.color = 'FF3EB9D8' -- Guild Recruiter Color

GG.debug = false
GG.isPreRelease = true
GG.preReleaseType = 'Pre-Alpha'

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

-- Highlgiht Images
BLUE_HIGHLIGHT = 'bags-glow-heirloom'
BLUE_LONG_HIGHLIGHT = 'communitiesfinder_card_highlight'