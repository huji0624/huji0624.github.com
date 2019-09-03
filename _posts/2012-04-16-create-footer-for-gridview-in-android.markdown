---
author: huji0624
comments: true
date: 2012-04-16 06:03:53+00:00
layout: post
slug: create-footer-for-gridview-in-android
title: Create Footer for Gridview in Android
wordpress_id: 439
categories:
- Android
---

Firstly,thanks to this question on stackoverflow [Need to create Footer for Gridview in Android](http://stackoverflow.com/questions/8876596/need-to-create-footer-for-gridview-in-android),and my article is named by this.

let me put the code first:


    
    
    /**
     * used to display a grid view that can show a loadmore footerview.
     * 
     * @author huji
     * 
     */
    public class FooterableGridView extends RelativeLayout {
    
    	public static final int COUNT_PER_PAGE = 20;
    
    	private ViewGroup loadMoreLayout;
    	private GridView mGridView;
    
    	private TextView loadMoreTextView;
    
    	private TextView text;
    
    	private ProgressBar moreProgressBar;
    
    	private OnClickListener mLoadMoreClickListener;
    
    	public FooterableGridView(Context context, AttributeSet attrs) {
    		super(context, attrs);
    		init();
    	}
    
    	public FooterableGridView(Context context) {
    		super(context);
    		init();
    	}
    
    	private void init() {
    
    		mGridView = new GridView(getContext());
    
    		loadMoreLayout = (ViewGroup) LayoutInflater.from(getContext()).inflate(R.layout.course_load_more_layout, null);
    
    		loadMoreTextView = (TextView) loadMoreLayout.findViewById(R.id.load_more_textview);
    		moreProgressBar = (ProgressBar) loadMoreLayout.findViewById(R.id.load_more_progressbar);
    
    		loadMoreLayout.setOnClickListener(clickListener);
    		LayoutParams lp = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
    		lp.addRule(CENTER_HORIZONTAL);
    		lp.addRule(ALIGN_PARENT_BOTTOM);
    		loadMoreLayout.setLayoutParams(lp);
    		loadMoreLayout.setBackgroundResource(R.drawable.titlebackaground);
    
    		mGridView.setOnScrollListener(footerViewListener);
    
    		text = new TextView(getContext());
    		text.setText("加载中...");
    		LayoutParams lpt = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
    		lpt.addRule(CENTER_IN_PARENT);
    		text.setLayoutParams(lpt);
    
    		addView(mGridView);
    		addView(loadMoreLayout);
    		addView(text);
    		
    	}
    
    	public void setAdapter(ListAdapter adapter) {
    		mGridView.setAdapter(adapter);
    	}
    
    	public void setOnItemClickListener(OnItemClickListener itemclick) {
    		mGridView.setOnItemClickListener(itemclick);
    	}
    
    	public void setNumColumns(int num) {
    		mGridView.setNumColumns(num);
    	}
    
    	public GridView getGridView() {
    		return mGridView;
    	}
    
    	/**
    	 * called this method after load data from the internet compkete. has more
    	 * means if has more data to load.
    	 * 
    	 * @param hasmore
    	 */
    	public void loadComplete(boolean hasmore) {
    		loadMoreTextView.setVisibility(View.VISIBLE);
    		moreProgressBar.setVisibility(View.GONE);
    
    		if (text.getVisibility() == VISIBLE) {
    			text.setVisibility(View.GONE);
    			
    			TextView empty=new TextView(getContext());
    			empty.setText("暂无数据");
    			mGridView.setEmptyView(empty);
    		}
    
    		if (!hasmore) {
    			loadMoreLayout.setVisibility(View.GONE);
    			mGridView.setOnScrollListener(null);
    		}
    	}
    
    	public void setLoadMoreClickListener(OnClickListener listener) {
    		mLoadMoreClickListener = listener;
    	}
    
    	private OnScrollListener footerViewListener = new OnScrollListener() {
    
    		@Override
    		public void onScrollStateChanged(AbsListView view, int scrollState) {
    			// TODO Auto-generated method stub
    
    		}
    
    		@Override
    		public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {
    			if (firstVisibleItem == 0 && visibleItemCount == 0 && totalItemCount == 0) {
    				return;
    			}
    
    			if (firstVisibleItem + visibleItemCount == totalItemCount) {
    				if (loadMoreLayout.getVisibility() == View.GONE) {
    					loadMoreLayout.setVisibility(View.VISIBLE);
    				}
    			} else {
    				if (loadMoreLayout.getVisibility() == View.VISIBLE) {
    					loadMoreLayout.setVisibility(View.GONE);
    				}
    			}
    		}
    	};
    
    	private OnClickListener clickListener = new OnClickListener() {
    
    		@Override
    		public void onClick(View v) {
    			if (v.getVisibility() == INVISIBLE) {
    				return;
    			}
    
    			loadMoreTextView.setVisibility(View.GONE);
    			moreProgressBar.setVisibility(View.VISIBLE);
    
    			if (mLoadMoreClickListener != null) {
    				mLoadMoreClickListener.onClick(v);
    			}
    		}
    	};
    }
    



here is the layout file:


    
    
    
    <relativelayout android:layout_width="match_parent" android:visibility="gone" xmlns:android="http://schemas.android.com/apk/res/android" android:padding="15dp" android:gravity="center" android:layout_height="match_parent">
    
        <textview android:layout_width="wrap_content" android:id="@+id/load_more_textview" android:layout_centerinparent="true" android:layout_height="wrap_content" android:textsize="23sp" android:text="点击加载更多"></textview>
    
        <progressbar android:layout_width="wrap_content" android:id="@+id/load_more_progressbar" android:layout_height="wrap_content" android:layout_centerinparent="true"></progressbar>
    
    </relativelayout>
    



使用这段代码可以为GridView创造一个类似FooterVIew的效果，我说类似，是因为这里的FooterView不是在所有列表项之后，而是浮在GridView之上的一个View，主要利用了Onscrollistener，当GridView滑动到底部的时候，就把加载更多的View显示出来，否则则置为Gone或者Invisibility，把这个View浮在GridView的底部居中的位置，能实现类似的效果。
