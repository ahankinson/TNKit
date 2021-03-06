/*
 * TNToolbar.j
 *
 * Copyright (C) 2010  Antoine Mercadal <antoine.mercadal@inframonde.eu>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3.0 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

@import <Foundation/Foundation.j>

@import <AppKit/CPImage.j>
@import <AppKit/CPImageView.j>
@import <AppKit/CPToolbar.j>
@import <AppKit/CPToolbarItem.j>
@import <AppKit/CPView.j>


var TNToolbarSelectedBgImage,
    TNToolbarSelectedBgImageHUD;

/*! @ingroup tnkit
    subclass of CPToolbar that allow dynamic insertion and item selection
*/
@implementation TNToolbar  : CPToolbar
{
    CPArray         _customSubViews         @accessors(property=customSubViews);
    CPToolbarItem   _selectedToolbarItem    @accessors(getter=selectedToolbarItem);

    BOOL            _iconSelected;
    CPArray         _sortedToolbarItems;
    CPDictionary    _toolbarItems;
    CPDictionary    _toolbarItemsOrder;
    CPImageView     _imageViewSelection;

    BOOL            _isHUD;
}


#pragma mark -
#pragma mark Initialization

+ (void)initialize
{
    var bundle = [CPBundle bundleForClass:TNToolbar];

    TNToolbarSelectedBgImage = [[CPThreePartImage alloc] initWithImageSlices:[
        [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"TNToolbar/toolbar-item-selected-left.png"] size:CGSizeMake(3.0, 60.0)],
        [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"TNToolbar/toolbar-item-selected-center.png"] size:CGSizeMake(1.0, 60.0)],
        [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"TNToolbar/toolbar-item-selected-right.png"] size:CGSizeMake(3.0, 60.0)]
    ] isVertical:NO];

    TNToolbarSelectedBgImageHUD = [[CPThreePartImage alloc] initWithImageSlices:[
        [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"TNToolbar/toolbar-hud-item-selected-left.png"] size:CGSizeMake(1.0, 60.0)],
        [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"TNToolbar/toolbar-hud-item-selected-center.png"] size:CGSizeMake(1.0, 60.0)],
        [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"TNToolbar/toolbar-hud-item-selected-right.png"] size:CGSizeMake(1.0, 60.0)]
    ] isVertical:NO];
}

/*! initialize the class with a target
    @param aTarget the target
    @return a initialized instance of TNToolbar
*/
- (id)init
{
    if (self = [super init])
    {
        _toolbarItems           = [CPDictionary dictionary];
        _toolbarItemsOrder      = [CPDictionary dictionary];
        _imageViewSelection     = [[CPImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 60.0, 60.0)];
        _iconSelected           = NO;
        _customSubViews         = [CPArray array];

        [_imageViewSelection setBackgroundColor:[CPColor colorWithPatternImage:TNToolbarSelectedBgImage]];

        [self setDelegate:self];
    }

    return self;
}

/*! initialize the class with HUD Style
    @return a initialized instance of TNToolbar
*/
- (id)initWithHUDStyle
{
    if (self = [self init])
    {
        var bundle = [CPBundle bundleForClass:[self class]];

        _isHUD = YES;

        [[self _toolbarView] setBackgroundColor:
            [CPColor colorWithPatternImage:
                [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"TNToolbar/toolbar-hud-background.png"] size:CGSizeMake(1.0, 59.0)]]];

        [_imageViewSelection setBackgroundColor:[CPColor colorWithPatternImage:TNToolbarSelectedBgImageHUD]];
    }

    return self;
}

#pragma mark -
#pragma mark Accesors

/*! return the actual view of the CPToolBar
    Usefull for hacks.
*/
- (CPView)toolbarView
{
    return _toolbarView;
}

#pragma mark -
#pragma mark Content management

/*! add given item with the given indentifier
    @param anItem the ToolbarItem to add
    @param anIdentifier the identifer to use for the item
*/
- (void)addItem:(CPToolbarItem)anItem withIdentifier:(CPString)anIdentifier
{
    [_toolbarItems setObject:anItem forKey:anIdentifier];
}

/*! add a new CPToolbarItem with a custom view
    @param anIdentifier CPString containing the identifier
    @param aLabel CPString containing the label
    @param anImage CPImage containing the icon of the item
    @param aTarget an object that will be the target of the item
    @param anAction a selector of the aTarget to perform on click
    @param toolTip the toolTip
*/
- (CPToolbarItem)addItemWithIdentifier:(CPString)anIdentifier label:(CPString)aLabel view:(CPView)aView target:(id)aTarget action:(SEL)anAction toolTip:(CPString)aToolTip
{
    var newItem = [[CPToolbarItem alloc] initWithItemIdentifier:anIdentifier];

    [newItem setLabel:aLabel];
    [newItem setView:aView];
    [newItem setTarget:aTarget];
    [newItem setAction:anAction];
    [newItem setToolTip:aToolTip];

    [_toolbarItems setObject:newItem forKey:anIdentifier];

    return newItem;
}

/*! add a new CPToolbarItem with a custom view
    @param anIdentifier CPString containing the identifier
    @param aLabel CPString containing the label
    @param anImage CPImage containing the icon of the item
    @param aTarget an object that will be the target of the item
    @param anAction a selector of the aTarget to perform on click
*/
- (CPToolbarItem)addItemWithIdentifier:(CPString)anIdentifier label:(CPString)aLabel view:(CPView)aView target:(id)aTarget action:(SEL)anAction
{
    return [self addItemWithIdentifier:anIdentifier label:aLabel view:aView target:aTarget action:anAction toolTip:nil];
}


/*! add a new CPToolbarItem
    @param anIdentifier CPString containing the identifier
    @param aLabel CPString containing the label
    @param anImage CPImage containing the icon of the item
    @param anotherImage CPImage containing the alternative icon of the item
    @param aTarget an object that will be the target of the item
    @param anAction a selector of the aTarget to perform on click
    @param toolTip the toolTip
*/
- (CPToolbarItem)addItemWithIdentifier:(CPString)anIdentifier label:(CPString)aLabel icon:(CPImage)anImage altIcon:(CPImage)anotherImage target:(id)aTarget action:(SEL)anAction toolTip:(CPString)aToolTip
{
    var newItem = [[CPToolbarItem alloc] initWithItemIdentifier:anIdentifier];

    [newItem setLabel:aLabel];
    [newItem setImage:[[CPImage alloc] initWithContentsOfFile:anImage size:CGSizeMake(32,32)]];
    if (anotherImage)
        [newItem setAlternateImage:[[CPImage alloc] initWithContentsOfFile:anotherImage size:CGSizeMake(32,32)]];
    [newItem setTarget:aTarget];
    [newItem setAction:anAction];
    [newItem setToolTip:aToolTip];

    [_toolbarItems setObject:newItem forKey:anIdentifier];

    return newItem;
}

/*! add a new CPToolbarItem
    @param anIdentifier CPString containing the identifier
    @param aLabel CPString containing the label
    @param anImage CPImage containing the icon of the item
    @param aTarget an object that will be the target of the item
    @param anAction a selector of the aTarget to perform on click
    @param toolTip the toolTip
*/
- (CPToolbarItem)addItemWithIdentifier:(CPString)anIdentifier label:(CPString)aLabel icon:(CPImage)anImage target:(id)aTarget action:(SEL)anAction toolTip:(CPString)aToolTip
{
    return [self addItemWithIdentifier:anIdentifier label:aLabel icon:anImage altIcon:nil target:aTarget action:anAction toolTip:nil];
}

/*! add a new CPToolbarItem
    @param anIdentifier CPString containing the identifier
    @param aLabel CPString containing the label
    @param anImage CPImage containing the icon of the item
    @param aTarget an object that will be the target of the item
    @param anAction a selector of the aTarget to perform on click
*/
- (CPToolbarItem)addItemWithIdentifier:(CPString)anIdentifier label:(CPString)aLabel icon:(CPImage)anImage target:(id)aTarget action:(SEL)anAction
{
    return [self addItemWithIdentifier:anIdentifier label:aLabel icon:anImage target:aTarget action:anAction toolTip:nil];
}

- (void)removeItemWithIdentifier:(CPString)anIdentifier
{
    [_toolbarItems removeObjectForKey:anIdentifier];

    var keys = [_toolbarItemsOrder allKeysForObject:anIdentifier];
    for (var i = [keys count] - 1; i >= 0; i--)
        [_toolbarItemsOrder removeObjectForKey:keys[i]];
}


/*! define the position of a given existing CPToolbarItem according to its identifier
    @param anIndentifier CPString containing the identifier
*/
- (void)setPosition:(CPNumber)aPosition forToolbarItemIdentifier:(CPString)anIndentifier
{
    [_toolbarItemsOrder setObject:anIndentifier forKey:aPosition];
}

/*! @ignore
*/
- (void)_reloadToolbarItems
{
    var sortFunction = function(a, b, context){
        var indexA = a,
            indexB = b;
        if (a < b)
                return CPOrderedAscending;
            else if (a > b)
                return CPOrderedDescending;
            else
                return CPOrderedSame;
        },
        sortedKeys = [[_toolbarItemsOrder allKeys] sortedArrayUsingFunction:sortFunction];

    _sortedToolbarItems = [CPArray array];

    for (var i = 0, c = [sortedKeys count]; i < c; i++)
    {
        var key = sortedKeys[i];
        [_sortedToolbarItems addObject:[_toolbarItemsOrder objectForKey:key]];
    }

    [super _reloadToolbarItems];

    if (_iconSelected)
        [_toolbarView addSubview:_imageViewSelection positioned:CPWindowBelow relativeTo:nil];

    for (var i = 0, c = [_customSubViews count]; i < c; i++)
        [_toolbarView addSubview:_customSubViews[i]];

    if (_isHUD)
    {
        var items = [self items],
            count = [items count];

        while (count--)
            [[_toolbarView viewForItem:items[count]] FIXME_setIsHUD:YES];
    }
}

/*! reloads all the items in the toolbar
*/
- (void)reloadToolbarItems
{
    [self _reloadToolbarItems];
}


#pragma mark -
#pragma mark Item selection

/*! make the item identified by the given identifier selected
    @param aToolbarItem the toolbaritem you want to select
*/
- (void)selectToolbarItem:(CPToolbarItem)aToolbarItem
{
    var toolbarItemView,
        subviews = [_toolbarView subviews];

    for (var i = 0, c = [subviews count]; i < c; i++)
    {
        toolbarItemView = subviews[i];

        if ([toolbarItemView._toolbarItem itemIdentifier] === [aToolbarItem itemIdentifier])
            break;
    }
    var frame = [toolbarItemView convertRect:[toolbarItemView bounds] toView:_toolbarView],
        labelFrame = [aToolbarItem label] ? [[aToolbarItem label] sizeWithFont:[CPFont boldSystemFontOfSize:12]] : [aToolbarItem minSize];
    _iconSelected = YES;

    [_imageViewSelection setFrameSize:CGSizeMake(MAX(labelFrame.width + 4, 50.0), 60.0)];
    [_imageViewSelection setFrameOrigin:CGPointMake(CGRectGetMinX(frame) + (CGRectGetWidth(frame) - CGRectGetWidth([_imageViewSelection frame])) / 2.0, 0.0)];

    [_toolbarView addSubview:_imageViewSelection positioned:CPWindowBelow relativeTo:nil];

    _selectedToolbarItem = aToolbarItem;
}

/*! deselect current selected item
*/
- (void)deselectToolbarItem
{
    _selectedToolbarItem    = nil;
    _iconSelected           = NO;
    [_imageViewSelection removeFromSuperview];
}

/*! get the toolbar item with the given identifier
*/
- (CPToolbarItem)itemWithIdentifier:(id)anIdentifier
{
    // for (var i = 0; i < [[self visibleItems] count]; i++)
    // {
    //     if ([[self visibleItems][i] itemIdentifier] == anIdentifier)
    //         return [self visibleItems][i];
    // }

    return [_toolbarItems objectForKey:anIdentifier];
}

#pragma mark -
#pragma mark CPToolbar DataSource implementation

/*! CPToolbar Protocol
*/
- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar
{
    return  _sortedToolbarItems;
}

/*! CPToolbar Protocol
*/
- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
    return  _sortedToolbarItems;
}

/*! CPToolbar Protocol
*/
- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
    var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier:anItemIdentifier];

    return ([_toolbarItems objectForKey:anItemIdentifier]) ? [_toolbarItems objectForKey:anItemIdentifier] : toolbarItem;
}


@end
