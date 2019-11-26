#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, SFAItemAlias) {
    SFAItemAliasConnectors = 0,
    SFAItemAliasTop = 1,
    SFAItemAliasHome = 2,
    SFAItemAliasRoot = 3,
    SFAItemAliasBox = 4,
    SFAItemAliasMyFolders = 5,
    SFAItemAliasFavorites = 6,
    SFAItemAliasSharepointConnectors = 7,
    SFAItemAliasNetworkShareConnectors = 8
};

static const char *const ItemAliasCStrings[] = { "connectors", "top", "home", "root", "box", "myfolders", "favorites", "sharepointconnectors", "networkshareconnectors" };
