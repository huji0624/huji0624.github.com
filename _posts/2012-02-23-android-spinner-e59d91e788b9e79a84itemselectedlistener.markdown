---
author: huji0624
comments: true
date: 2012-02-23 16:27:17+00:00
layout: post
slug: android-spinner-%e5%9d%91%e7%88%b9%e7%9a%84itemselectedlistener
title: Android Spinner 坑爹的ItemSelectedListener
wordpress_id: 382
categories:
- Android
---

偶然发现，Spinner的ItemSelectedListener在第一次设置Adapter的时候，就会被触发一次，相当于position为0的Item被按下了。找了半天没找到相应的设置API，网上也没有说有什么比较优美的解决方法。

俗话说，慢慢来比较快，慢慢读下源码：

ItemSelectedListener最终被调用是在下面这个函数：


    
    
    private void fireOnSelected() {
            if (mOnItemSelectedListener == null)
                return;
    
            int selection = this.getSelectedItemPosition();
            if (selection >= 0) {
                View v = getSelectedView();
                mOnItemSelectedListener.onItemSelected(this, v, selection,
                        getAdapter().getItemId(selection));
            } else {
                mOnItemSelectedListener.onNothingSelected(this);
            }
        }
    



然后：


    
    
        void selectionChanged() {
            if (mOnItemSelectedListener != null) {
                if (mInLayout || mBlockLayoutRequests) {
                    // If we are in a layout traversal, defer notification
                    // by posting. This ensures that the view tree is
                    // in a consistent state and is able to accomodate
                    // new layout or invalidate requests.
                    if (mSelectionNotifier == null) {
                        mSelectionNotifier = new SelectionNotifier();
                    }
                    post(mSelectionNotifier);
                } else {
                    fireOnSelected();
                }
            }
    
            // we fire selection events here not in View
            if (mSelectedPosition != ListView.INVALID_POSITION && isShown() && !isInTouchMode()) {
                sendAccessibilityEvent(AccessibilityEvent.TYPE_VIEW_SELECTED);
            }
        }
    
    void checkSelectionChanged() {
            if ((mSelectedPosition != mOldSelectedPosition) || (mSelectedRowId != mOldSelectedRowId)) {
                selectionChanged();
                mOldSelectedPosition = mSelectedPosition;
                mOldSelectedRowId = mSelectedRowId;
            }
        }
    



发现选中的不是上一次的时候，Listener就会被触发。

然后再找到void handleDataChanged()函数，会发现，只要Adapter中的count大于0，ItemSelectedListener会被调用并且传入0到最大值-1的值，也就是肯定会选中一个，count=0时，会传一个invalidateposition，貌似是-1。再看看handleDataChanged()函数是在什么时候被调用的。可以发现在AbsSpinner的OnMeasure方法中和Spinner的layout方法中都被调用了。在给spinner setAdapter的时候，会发现调用了requestlayout，也就是会使试图树重新layout一下，如果其中的mDataChanged为true，最终就会调用一次ItemSelectListener，目前发现的方法就是只有自己设置一个默认的position，当选择的position不是上一次的时候，才调用ItemSelectListener里的东西，否则就返回。关于mDataChanged是怎么被设为true的，目前还没太跟到，但都setAdapter了，这个应该是true了。

