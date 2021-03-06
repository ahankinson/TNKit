/*
 * TNTabView.j
 *
 * Copyright (C) 2010 Antoine Mercadal <antoine.mercadal@inframonde.eu>
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

@import <Foundation/Foundation.j>

@import <AppKit/CPButton.j>
@import <AppKit/CPControl.j>
@import <AppKit/CPTabViewItem.j>
@import <AppKit/CPTheme.j>
@import <AppKit/CPView.j>
@import <AppKit/CPScrollView.j>

@import "TNSwipeView.j"


var TNTabViewTabMargin = 2.0,
    TNTabViewTabsBackgroundColor,
    TNTabViewTabButtonColorNormal,
    TNTabViewTabButtonColorPressed,
    TNTabViewTabButtonColorActive,
    TNTabViewTabButtonRightBezelColorNormal,
    TNTabViewTabButtonLeftBezelColorNormal,
    TNTabViewTabButtonRightBezelColorPressed,
    TNTabViewTabButtonLeftBezelColorPressed;

TNTabItemPrototypeThemeStateSelected = CPThemeState("TNTabItemPrototypeThemeStateSelected");

/*! @ingroup tnkit
    This class represent the prototype of a TNTabView item
    you can overide it and use setTabItemViewPrototype: of TNTabView
    to implement your own item view
*/
@implementation TNTabItemPrototype : CPControl
{
    CPButton    _label  @accessors(getter=label);
    int         _index  @accessors(property=index);
}


#pragma mark -
#pragma mark class methods

+ (void)initialize
{
    TNTabViewTabButtonColorNormal = [CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:[
                    [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:TNTabView] pathForResource:@"TNTabView/tabitem-normal-left.png"] size:CGSizeMake(9, 22)],
                    [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:TNTabView] pathForResource:@"TNTabView/tabitem-normal-center.png"] size:CGSizeMake(1, 22)],
                    [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:TNTabView] pathForResource:@"TNTabView/tabitem-normal-right.png"] size:CGSizeMake(9, 22)]]
                isVertical:NO]];
    TNTabViewTabButtonColorPressed = [CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:[
                    [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:TNTabView] pathForResource:@"TNTabView/tabitem-pressed-left.png"] size:CGSizeMake(9, 22)],
                    [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:TNTabView] pathForResource:@"TNTabView/tabitem-pressed-center.png"] size:CGSizeMake(1, 22)],
                    [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:TNTabView] pathForResource:@"TNTabView/tabitem-pressed-right.png"] size:CGSizeMake(9, 22)]]
                isVertical:NO]];
    TNTabViewTabButtonColorActive = [CPColor colorWithPatternImage:[[CPThreePartImage alloc] initWithImageSlices:[
                    [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:TNTabView] pathForResource:@"TNTabView/tabitem-active-left.png"] size:CGSizeMake(9, 22)],
                    [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:TNTabView] pathForResource:@"TNTabView/tabitem-active-center.png"] size:CGSizeMake(1, 22)],
                    [[CPImage alloc] initWithContentsOfFile:[[CPBundle bundleForClass:TNTabView] pathForResource:@"TNTabView/tabitem-active-right.png"] size:CGSizeMake(9, 22)]]
                isVertical:NO]];
}

/*! return the actual size of a TNTabItemPrototype
    This is used to layout the TNTabView
*/
+ (CGSize)size
{
    return CGSizeMake(115.0, 25.0);
}

- (CGSize)size
{
    return [[self class] size];
}

#pragma mark -
#pragma mark Initialization

/*! initialize a new TNTabItemPrototype
*/
- (TNTabItemPrototype)initWithFrame:(CGRect)aFrame
{
    if (self = [super initWithFrame:aFrame])
    {
        _label = [[CPButton alloc] initWithFrame:CGRectMake(0, 0, [TNTabItemPrototype size].width - TNTabViewTabMargin, 22)];
        [_label setAutoresizingMask:CPViewMinXMargin | CPViewMinYMargin];

        [self prepareTheme];

        [self addSubview:_label];

        [_label setTarget:self];
        [_label setAction:@selector(_didClick:)];
        _index = -1;
    }

    return self;
}

- (void)prepareTheme
{
    [_label setValue:TNTabViewTabButtonColorNormal forThemeAttribute:@"bezel-color" inState:CPThemeStateNormal];
    [_label setValue:TNTabViewTabButtonColorPressed forThemeAttribute:@"bezel-color" inState:CPThemeStateHighlighted];
    [_label setValue:TNTabViewTabButtonColorActive forThemeAttribute:@"bezel-color" inState:TNTabItemPrototypeThemeStateSelected];
    [_label setValue:[CPColor whiteColor] forThemeAttribute:@"text-color" inState:CPThemeStateHighlighted];
    [_label setValue:[CPColor blackColor] forThemeAttribute:@"text-shadow-color" inState:CPThemeStateHighlighted];
    [_label setValue:[CPColor whiteColor] forThemeAttribute:@"text-color" inState:TNTabItemPrototypeThemeStateSelected];
    [_label setValue:[CPColor blackColor] forThemeAttribute:@"text-shadow-color" inState:TNTabItemPrototypeThemeStateSelected];
}


/*! @ignore
*/
- (IBAction)_didClick:(id)aSender
{
    [[self target] performSelector:[self action] withObject:self];
}

#pragma mark -
#pragma mark overrides

/*! called to set the content of the view
    from the CPTabViewItem passed by TNTabView
    @passed anItem the CPTabViewItem
*/
- (void)setObjectValue:(CPTabView)anItem
{
    [_label unbind:@"title"];
    [_label bind:@"title" toObject:anItem withKeyPath:@"label" options:nil];
}

/*! used to set theme state of subviews
    @param aThemeState the theme state
*/
- (BOOL)setThemeState:(CPThemeState)aThemeState
{
    [_label setThemeState:aThemeState];

    return YES;
}

/*! used to unset theme state of subviews
    @param aThemeState the theme state
*/
- (BOOL)unsetThemeState:(CPThemeState)aThemeState
{
    [_label unsetThemeState:aThemeState];

    return YES;
}

/*! CPCoder compliance
*/
- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
        _label  = [aCoder decodeObjectForKey:@"_label"];

    return self;
}

/*! CPCoder compliance
*/
- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:_label forKey:@"_label"];
}

@end


/*! @ingroup tnkit
    this class is a sort of CPTabView (protocol compliant)
    but that uses a TNSwipeView
*/
@implementation TNTabView : CPControl
{
    id                          _delegate               @accessors(property=delegate);
    BOOL                        _enableManualScrolling  @accessors(property=enableManualScrolling);

    CPArray                     _itemObjects;
    CPButton                    _buttonScrollLeft;
    CPButton                    _buttonScrollRight;
    CPView                      _currentSelectedItemView;
    CPView                      _viewTabsDocument;
    int                         _currentSelectedIndex;
    CPView                      _contentView;
    TNTabItemPrototype          _tabItemViewPrototype;
    CPScrollView                _scrollViewTabs;
    BOOL                        _needsScroll;
}


#pragma mark -
#pragma mark Initialization

/*! initialize the TNTabView
    @param aFrame the frame of the view
*/
- (TNTabView)initWithFrame:(CGRect)aFrame
{
    if (self = [super initWithFrame:aFrame])
    {
        if (!TNTabViewTabsBackgroundColor)
        {
            var bundle = [CPBundle bundleForClass:[self class]];
            TNTabViewTabsBackgroundColor = [CPColor colorWithPatternImage:[[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"TNTabView/tabs-background.png"]]];
            TNTabViewTabButtonRightBezelColorNormal = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"TNTabView/scroll-button-right-bezel.png"]];
            TNTabViewTabButtonLeftBezelColorNormal = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"TNTabView/scroll-button-left-bezel.png"]];
            TNTabViewTabButtonRightBezelColorPressed = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"TNTabView/scroll-button-right-bezel-pressed.png"]];
            TNTabViewTabButtonLeftBezelColorPressed = [[CPImage alloc] initWithContentsOfFile:[bundle pathForResource:@"TNTabView/scroll-button-left-bezel-pressed.png"]];
        }

        _viewTabsDocument = [[CPView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, [TNTabItemPrototype size].height)];

        _scrollViewTabs = [[CPScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(aFrame), [TNTabItemPrototype size].height)];
        [_scrollViewTabs setAutoresizingMask:CPViewWidthSizable];
        [_scrollViewTabs setAutohidesScrollers:YES];
        [_scrollViewTabs setDocumentView:_viewTabsDocument];
        [_scrollViewTabs setHasVerticalScroller:NO];
        [_scrollViewTabs setHasHorizontalScroller:NO];

        _contentView = [[CPView alloc] initWithFrame:CGRectMake(0, [TNTabItemPrototype size].height, CGRectGetWidth(aFrame), CGRectGetHeight(aFrame) - [TNTabItemPrototype size].height)];
        [_contentView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

        _currentSelectedIndex = -1;
        _needsScroll = NO;
        _enableManualScrolling = YES;
        _itemObjects = [CPArray array];

        _tabItemViewPrototype = [[TNTabItemPrototype alloc] initWithFrame:CGRectMake(0.0, 0.0, [TNTabItemPrototype size].width, [TNTabItemPrototype size].height)];

        _buttonScrollRight = [CPButton buttonWithTitle:@">"];
        [_buttonScrollRight setBordered:NO];
        [_buttonScrollRight setImage:TNTabViewTabButtonRightBezelColorNormal]; // this avoid the blinking..
        [_buttonScrollRight setValue:TNTabViewTabButtonRightBezelColorNormal forThemeAttribute:@"image"];
        [_buttonScrollRight setValue:TNTabViewTabButtonRightBezelColorPressed forThemeAttribute:@"image" inState:CPThemeStateHighlighted];
        [_buttonScrollRight setFrame:CGRectMake(20.0, 0.0, 20.0, [TNTabItemPrototype size].height)];
        [_buttonScrollRight setContinuous:YES];
        [_buttonScrollRight setTarget:_scrollViewTabs];
        [_buttonScrollRight setAction:@selector(moveRight:)];

        _buttonScrollLeft = [CPButton buttonWithTitle:@"<"];
        [_buttonScrollLeft setBordered:NO];
        [_buttonScrollLeft setImage:TNTabViewTabButtonLeftBezelColorNormal]; // this avoid the blinking..
        [_buttonScrollLeft setValue:TNTabViewTabButtonLeftBezelColorNormal forThemeAttribute:@"image"];
        [_buttonScrollLeft setValue:TNTabViewTabButtonLeftBezelColorPressed forThemeAttribute:@"image" inState:CPThemeStateHighlighted];
        [_buttonScrollLeft setFrame:CGRectMake(0.0, 0.0, 20.0, [TNTabItemPrototype size].height)];
        [_buttonScrollLeft setContinuous:YES];
        [_buttonScrollLeft setTarget:_scrollViewTabs];
        [_buttonScrollLeft setAction:@selector(moveLeft:)];


        [self addSubview:_scrollViewTabs];
        [self addSubview:_contentView];
        [self setTabViewBackgroundColor:TNTabViewTabsBackgroundColor];
        [self setNeedsLayout];
    }

    return self;
}


#pragma mark -
#pragma mark Getters / Setters

/*! set the background color for the tabs view
    @param aColor the color
*/
- (void)setTabViewBackgroundColor:(CPColor)aColor
{
    [_viewTabsDocument setBackgroundColor:aColor];
}

/*! set the background color for the tabs view
    @param aColor the color
*/
- (void)setContentBackgroundColor:(CPColor)aColor
{
    [_contentView setBackgroundColor:aColor];
}

/*! set the prototype view for items
    @param anItemPrototype a subclass of TNTabItemPrototype that represent the prototype
*/
- (void)setTabItemViewPrototype:(TNTabItemPrototype)anItemPrototype
{
    _tabItemViewPrototype = anItemPrototype;
}

/*! @ignore
    Returns a new copy of the current item view prototype
    @return a new copy of current TNTabItemPrototype
*/
- (void)_newTabItemPrototype
{
    return [CPKeyedUnarchiver unarchiveObjectWithData:[CPKeyedArchiver archivedDataWithRootObject:_tabItemViewPrototype]];
}

- (void)_getTabItemAtIndex:(int)anIndex
{
    if (anIndex == -1 || anIndex >= [_itemObjects count])
        return nil;

    return _itemObjects[anIndex][0];
}

- (void)_getTabViewAtIndex:(int)anIndex
{
    if (anIndex >= [_itemObjects count])
        return nil;

    return _itemObjects[anIndex][1];
}

#pragma mark -
#pragma mark Events

/*! stop the event progation
*/
- (void)mouseDown:(CPEvent)anEvent
{
}

#pragma mark -
#pragma mark CPTabView protocol

/*! implement CPTabViewProtocol
    see documentation for CPTabView
*/
- (void)addTabViewItem:(CPTabViewItem)anItem
{
    [self insertTabViewItem:anItem atIndex:[_itemObjects count]];
}

/*! implement CPTabViewProtocol
    see documentation for CPTabView
*/
- (void)insertTabViewItem:(CPTabViewItem)anItem atIndex:(int)anIndex
{
    var shouldSelectFirstTab = NO;
    if (_currentSelectedIndex == -1)
    {
        shouldSelectFirstTab = YES;
        _currentSelectedIndex = 0;
    }

    var previousSelectedItem = [self selectedTabViewItem],
        itemView = [self _newTabItemPrototype];

    [itemView setObjectValue:anItem];
    [itemView setTarget:self];
    [itemView setAction:@selector(_tabItemCliked:)];
    [_itemObjects insertObject:[anItem, itemView] atIndex:anIndex];

    if (previousSelectedItem)
        [self selectTabViewItem:previousSelectedItem];

    [_viewTabsDocument addSubview:itemView];
    [self setNeedsLayout];

    if (_delegate && [_delegate respondsToSelector:@selector(tabViewDidChangeNumberOfTabViewItems:)])
        [_delegate tabViewDidChangeNumberOfTabViewItems:self];

    if (shouldSelectFirstTab)
        [self selectFirstTabViewItem:nil];
}


/*! implement CPTabViewProtocol
    see documentation for CPTabView
*/
- (int)indexOfTabViewItem:(CPTabViewItem)anItem
{
    for (var i = 0, c = [_itemObjects count]; i < c; i++)
        if ([self _getTabItemAtIndex:i] == anItem)
            return i;

    return -1;
}

/*! implement CPTabViewProtocol
    see documentation for CPTabView
*/
- (int)indexOfTabViewItemWithIdentifier:(CPString)anIdentifer
{
    for (var i = 0, c = [_itemObjects count]; i < c; i++)
        if ([[self _getTabItemAtIndex:i] identifier] == anIdentifer)
            return i;
    return -1;
}

/*! implement CPTabViewProtocol
    see documentation for CPTabView
*/
- (void)numberOfTabViewItems
{
    return [_itemObjects count];
}

/*! implement CPTabViewProtocol
    see documentation for CPTabView
*/
- (void)removeTabViewItem:(CPTabViewItem)anItem
{
    if (_currentSelectedIndex == -1)
        return;

    var itemIndex = [self indexOfTabViewItemWithIdentifier:[anItem identifier]],
        currentItemView = [self _getTabViewAtIndex:itemIndex],
        associatedView = [[self _getTabItemAtIndex:itemIndex] view];

    [associatedView removeFromSuperview];

    [currentItemView removeFromSuperview];
    [_itemObjects removeObjectAtIndex:[self indexOfTabViewItemWithIdentifier:[anItem identifier]]];

    [self setNeedsLayout];

    if ([_itemObjects count] == 0)
        _currentSelectedIndex = -1;
    else if (_currentSelectedIndex >= [_itemObjects count])
        [self selectLastTabViewItem:nil];

    if (_delegate && [_delegate respondsToSelector:@selector(tabViewDidChangeNumberOfTabViewItems:)])
        [_delegate tabViewDidChangeNumberOfTabViewItems:self];
}

/*! implement CPTabViewProtocol
    see documentation for CPTabView
*/
- (void)selectTabViewItem:(CPTabViewItem)anItem
{
    [self selectTabViewItemAtIndex:[self indexOfTabViewItem:anItem]];
}

/*! implement CPTabViewProtocol
    see documentation for CPTabView
*/
- (void)selectedTabViewItem
{
    return [self _getTabItemAtIndex:_currentSelectedIndex];
}

/*! implement CPTabViewProtocol
    see documentation for CPTabView
*/
- (void)selectedTabViewIndex
{
    return _currentSelectedIndex;
}

/*! implement CPTabViewProtocol
    see documentation for CPTabView
*/
- (void)selectFirstTabViewItem:(id)aSender
{
    [self selectTabViewItemAtIndex:0];
}

/*! implement CPTabViewProtocol
    see documentation for CPTabView
*/
- (void)selectLastTabViewItem:(id)aSender
{
    if (_currentSelectedIndex == -1)
        return;

    [self selectTabViewItemAtIndex:[_itemObjects count] - 1];
}

/*! implement CPTabViewProtocol
    see documentation for CPTabView
*/
- (void)selectNextTabViewItem:(id)aSender
{
    if (_currentSelectedIndex == -1)
        return;

    [self selectTabViewItemAtIndex:(_currentSelectedIndex + 1)];
}

/*! implement CPTabViewProtocol
    see documentation for CPTabView
*/
- (void)selectPreviousTabViewItem:(id)aSender
{
    if (_currentSelectedIndex == -1)
        return;

    [self selectTabViewItemAtIndex:(_currentSelectedIndex - 1)];
}

/*! implement CPTabViewProtocol
    see documentation for CPTabView
*/
- (void)selectTabViewItemAtIndex:(int)anIndex
{
    if (_currentSelectedIndex == -1)
        return;

    var pendingItem = [self _getTabItemAtIndex:anIndex];

    if (_delegate && [_delegate respondsToSelector:@selector(tabView:shouldSelectTabViewItem:)])
        if (![_delegate tabView:self shouldSelectTabViewItem:pendingItem])
            return;

    [[[self selectedTabViewItem] view] removeFromSuperview];

    if (_delegate && [_delegate respondsToSelector:@selector(tabView:willSelectTabViewItem:)])
        [_delegate tabView:self willSelectTabViewItem:pendingItem];

    [_currentSelectedItemView unsetThemeState:TNTabItemPrototypeThemeStateSelected];
    _currentSelectedItemView = [self _getTabViewAtIndex:anIndex];
    [_currentSelectedItemView setThemeState:TNTabItemPrototypeThemeStateSelected];

    [[pendingItem view] setFrame:[_contentView bounds]];
    [_contentView addSubview:[pendingItem view]];

    _currentSelectedIndex = anIndex;

    if (_delegate && [_delegate respondsToSelector:@selector(tabView:didSelectTabViewItem:)])
        [_delegate tabView:self didSelectTabViewItem:pendingItem];

}

/*! implement CPTabViewProtocol
    see documentation for CPTabView
*/
- (CPTabViewItem)tabViewItemAtIndex:(int)anIndex
{
    return [self _getTabItemAtIndex:anIndex];
}

/*! implement CPTabViewProtocol
    see documentation for CPTabView
*/
- (CPArray)tabViewItems
{
    var ret = [CPArray array];
    for (var i = 0, c = [_itemObjects count]; i < c; i++)
        [ret addObject:[self _getTabItemAtIndex:i]];

    return ret;
}


#pragma mark -
#pragma mark Layouting

/*! layout the TNTabView
*/
- (void)layoutSubviews
{
    var minimalDocViewWidth = /*[[_scrollViewTabs horizontalScroller] isEnabled] ? [self frameSize].width - 40 : */[self frameSize].width,
        docViewWitdh = MAX(([_tabItemViewPrototype size].width * [_itemObjects count]), minimalDocViewWidth),
        currentXOrigin = (docViewWitdh / 2) - [_itemObjects count] * [_tabItemViewPrototype size].width / 2;

    if ([[_scrollViewTabs horizontalScroller] isEnabled])
    {
        // [_scrollViewTabs setFrameSize:CGSizeMake([self bounds].size.width - 40, [_tabItemViewPrototype size].height)];
        // [_scrollViewTabs setFrameOrigin:CGPointMake(40.0, 0.0)];
        if (_enableManualScrolling)
        {
            [self addSubview:_buttonScrollLeft];
            [self addSubview:_buttonScrollRight];
        }
    }
    else
    {
        // [_scrollViewTabs setFrameSize:CGSizeMake([self bounds].size.width, [_tabItemViewPrototype size].height)];
        // [_scrollViewTabs setFrameOrigin:CGPointMake(0.0, 0.0)];
        if (_enableManualScrolling)
        {
            [_buttonScrollRight removeFromSuperview];
            [_buttonScrollLeft removeFromSuperview];
        }
    }

    [_viewTabsDocument setFrameSize:CGSizeMake(docViewWitdh, [_tabItemViewPrototype size].height)];

    for (var i = 0, c = [_itemObjects count]; i < c; i++)
    {
        var item = [self _getTabItemAtIndex:i],
            itemView = [self _getTabViewAtIndex:i],
            view = [item view];

        [itemView setFrameOrigin:CGPointMake(currentXOrigin, 2.0)];
        [itemView setIndex:i];

        [view setFrame:[_contentView bounds]];

        currentXOrigin += [_tabItemViewPrototype size].width;
    }
}

/*! @ignore
*/
- (IBAction)_tabItemCliked:(id)aSender
{
    if (_currentSelectedIndex == [aSender index])
        return;

    [self selectTabViewItemAtIndex:[aSender index]];
}

@end


@implementation TNTabView (CPCoding)

/*! CPCoder compliance
*/
- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
    {
        _delegate                   = [aCoder decodeObjectForKey:@"_delegate"];
        _itemObjects                = [aCoder decodeObjectForKey:@"_itemObjects"];
        _currentSelectedItemView    = [aCoder decodeObjectForKey:@"_currentSelectedItemView"];
        _viewTabsDocument           = [aCoder decodeObjectForKey:@"_viewTabsDocument"];
        _currentSelectedIndex       = [aCoder decodeObjectForKey:@"_currentSelectedIndex"];
        _contentView                = [aCoder decodeObjectForKey:@"_contentView"];
        _tabItemViewPrototype       = [aCoder decodeObjectForKey:@"_tabItemViewPrototype"];
        _scrollViewTabs             = [aCoder decodeObjectForKey:@"_scrollViewTabs"];
    }

    return self;
}

/*! CPCoder compliance
*/
- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:_delegate forKey:@"_delegate"];
    [aCoder encodeObject:_itemObjects forKey:@"_itemObjects"];
    [aCoder encodeObject:_currentSelectedItemView forKey:@"_currentSelectedItemView"];
    [aCoder encodeObject:_viewTabsDocument forKey:@"_viewTabsDocument"];
    [aCoder encodeObject:_currentSelectedIndex forKey:@"_currentSelectedIndex"];
    [aCoder encodeObject:_contentView forKey:@"_contentView"];
    [aCoder encodeObject:_tabItemViewPrototype forKey:@"_tabItemViewPrototype"];
    [aCoder encodeObject:_scrollViewTabs forKey:@"_scrollViewTabs"];
}

@end
