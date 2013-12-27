//+------------------------------------------------------------------+
//|                                                     #motion2.mq4 |
//|                                    Copyright © 2009, Dylan Heyes |
//|                                              www.octadecimal.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Dylan Heyes"
#property link      "www.octadecimal.com"

// Version
//======================================================================================================================================
#define VERSION "2.2.1"

// Modules
//======================================================================================================================================
//-- Options and settings
#include <m2/2.2.1/#motion2_options.mqh>
#include <m2/2.2.1/#motion2_params.mqh>

//-- Utilities
#include <m2/2.2.1/#motion2_marketinfo.mqh>
#include <m2/2.2.1/#motion2_utils.mqh>
#include <m2/2.2.1/#motion2_sound.mqh>
#include <m2/2.2.1/#motion2_output.mqh>

//-- Data
#include <m2/2.2.1/#motion2_data.mqh>
#include <m2/2.2.1/#motion2_widgets-enums.mqh>
#include <m2/2.2.1/#motion2_fibonaccis-enums.mqh>
#include <m2/2.2.1/#motion2_positions-enums.mqh>

//-- Display
#include <m2/2.2.1/#motion2_objects.mqh>
#include <m2/2.2.1/#motion2_widgets.mqh>
#include <m2/2.2.1/#motion2_states.mqh>
#include <m2/2.2.1/#motion2_chart.mqh>
#include <m2/2.2.1/#motion2_gui.mqh>

//-- Engine
#include <m2/2.2.1/#motion2_fractals.mqh>
#include <m2/2.2.1/#motion2_fibonaccis.mqh>
#include <m2/2.2.1/#motion2_orders.mqh>
#include <m2/2.2.1/#motion2_positions.mqh>

//-- Input
#include <m2/2.2.1/#motion2_keyboard.mqh>

//-- Main
#include <m2/2.2.1/#motion2_main.mqh>


// Core Thread
//======================================================================================================================================
int _barsLast;

int init()
{
   main_Initialize();
   start();
   return(0);
}
int deinit()
{
	main_Deinitialize();
   return(0);
}
int start()
{
	if(!Realtime) tick();
	else
	{
   	while(!IsStopped())
   	{
      	RefreshRates();
      	tick();
      	Sleep(RefreshRate);
   	}
   }
   
   return(0);
}
void tick()
{
   if(_barsLast != Bars) { 
   	main_OnBarOpen(); 
   	_barsLast = Bars;
   }
   main_Update();
}


//+------------------------------------------------------------------+
//|                                                #motion2_main.mq4 |
//|                                    Copyright © 2009, Dylan Heyes |
//|                                              www.octadecimal.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Dylan Heyes"
#property link      "www.octadecimal.com"


// Variables
//======================================================================================================================================
bool _isInitialized=false;    // Used to guarantee Initialize is called only once, and not when params are changed.


// Initialize() - Main initialize call. Detects if it's a first time initialization, parameter change, or timeframe change.
//======================================================================================================================================
void main_Initialize()
{
   //-- First initialization
   if(!_isInitialized)
   {
      output_Line();
      output_Info("main_Initialize", "Motion2 starting... (version: "+VERSION+")");
      output_Info("main_Initialize", "Copyright © 2009, Dylan Heyes. All rights reserved.");
      output_Line();
      
      //-- Generate Session ID
      SessionID = NAME_PREFIX+Symbol()+"_"+Period()+TimeCurrent()+MathRand();
      
      //-- Initialize modules
      marketinfo_Initialize();
      chart_Initialize();
		keyboard_Initialize();
      gui_Initialize();
      fractals_Initialize();
      fibonaccis_Initialize();
      orders_Initialize();
      positions_Initialize();
   
      //-- Post-process
      sound_Play("initialized.wav");
      _isInitialized = true;
      output_Line();
      output_Info("main_Initialize", "Motion2 started. (version: "+VERSION+")");
      output_Info("main_Initialize", "Session ID: "+SessionID);
      output_Line();
   }
   else
   {
      //-- Force marketinfo refresh
      marketinfo_Update();
      
      //-- Triggered by period change
      if(marketinfo_PeriodChanged() > -1) 
      {
         output_Debug("main_Initialize", "Period changed.");
      }
      //-- Triggered by param change
      else 
      {
         output_Debug("main_Initialize", "Parameters changed.");
      }
   }
}

// Deinitialize() - Called upon EA removal, last code ever executed.
//======================================================================================================================================
void main_Deinitialize()
{
	output_Line();
	output_Info("deinit", "Motion stopped.  |  http://motion.octadecimal.com");
	output_Line();
	
   //-- Post-process
   sound_Play("deinitialized.wav");
}

// Update() - Main update thread.
//======================================================================================================================================
void main_Update()
{
	//-- Update modules
	marketinfo_Update();
	chart_Update();
	keyboard_Update();
	widgets_Update();
	fractals_Update();
   fibonaccis_Update();
   positions_Update();
   orders_Update();
   gui_Update();
}

// main_OnBarOpen() - Called upon new bar open.
//======================================================================================================================================
void main_OnBarOpen()
{
	//output_Trace("main_OnBarOpen","New bar: "+Bars);
	
	//-- Dispatch listeners
	fractals_BarOpen();
}



//+------------------------------------------------------------------+
//|                                              #motion2_params.mq4 |
//|                                                      Dylan Heyes |
//|                                              www.octadecimal.com |
//+------------------------------------------------------------------+
#property copyright "Dylan Heyes"
#property link      "www.octadecimal.com"

extern bool   Realtime		      =  true;
extern int    RefreshRate			=  5;

//-- Initial states
//extern string _label01           =  "___INITIAL STATES______________________________________";
extern int    ControlState       =  1;
extern int    DirectionState     =  1;
extern int    DrawingState       =  1;

//-- Fibonacci
//extern string _label02           =  "___FIBONACCI___________________________________________";
extern int	  FibTimeout			=  10;
extern int    ProfitIncrement    =  0.5;
extern string FibInterpolation   =  "linear";
extern double FibEntryThreshold  =  0.075;

//-- Fractals
extern int 	  FractalLookback		=  1;
extern bool	  AllowOlderFractals =	false;

//-- Orders
extern double Risk					=  0.02;
extern bool   CompensateSpread	=  true;
extern int    ProfitLevels       =  3;
extern double ProfitLevel1       =  0.5; 
extern double ProfitLevel2       =  1.0; 
extern double ProfitLevel3       =  1.5; 
extern double CloseLots1         =  0.5;
extern double CloseLots2         =  0.5;
extern double CloseLots3         =  0.0;
extern bool   SimulateLimits     =  true;
extern bool   MaxSimPipsOffset   =  2;
extern int    MaxPendingOrders   =  1;
extern int    MaxOpenOrders      =  1;
extern int    Slippage           =  2;


//+------------------------------------------------------------------+
//|                                              #motion2_orders.mq4 |
//|                                    Copyright © 2009, Dylan Heyes |
//|                                              www.octadecimal.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Dylan Heyes"
#property link      "www.octadecimal.com"

// Variables
//======================================================================================================================================
int	 _numOrders=0;


// Initialize()
//======================================================================================================================================
void orders_Initialize()
{
}

// Update() - Main orders update thread.
//======================================================================================================================================
void orders_Update()
{
	//-- Initialize
	int 	orderID, positionID, orderType;
	bool	isPending, isFilled, isBuy, isSell;
	
	//-- Loop through orders pool
	for(int i=0; i < OrdersTotal(); i++)
	{
		if(OrderSelect(i, SELECT_BY_POS))
		{
			//-- Ensure order belongs to session
			if(utils_StringTrim(OrderComment(), "[") == SessionID)
			{
				//-- Pre-process
				orderID = OrderMagicNumber();
				positionID = OrderParams[orderID][ORDER_POSITION];
				orderType = OrderType();
				isPending = orderType == OP_BUYSTOP || orderType == OP_SELLSTOP;
				isFilled = orderType == OP_BUY || orderType == OP_SELL;
				isBuy = orderType == OP_BUYSTOP || orderType == OP_BUY;
				isSell = orderType == OP_SELLSTOP || orderType == OP_SELL;
				
				//-- Open (pending)
				if(isPending && OrderParams[orderID][ORDER_STATUS]==STATUS_OPEN)
				{
				}
				
				//-- Detect initial fill
				if(isFilled && OrderParams[orderID][ORDER_STATUS]==STATUS_OPEN)
				{
					output_Debug("orders_Update","Order FILLED: position="+positionID+" id="+orderID);
					OrderParams[orderID][ORDER_STATUS]=STATUS_FILLED;
				}
				
				//-- Filled
				if(isFilled && OrderParams[orderID][ORDER_STATUS]==STATUS_FILLED)
				{
					
				}
			}
		}
	}
	
	for(i=0; i < OrdersHistoryTotal(); i++)
	{
		if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
		{
			//-- Ensure order belongs to session
			if(SessionID == utils_StringTrim(OrderComment(), "["))
			{
				//-- Pre-process
				orderID = OrderMagicNumber();
				positionID = OrderParams[orderID][ORDER_POSITION];
				orderType = OrderType();
				isPending = orderType == OP_BUYSTOP || orderType == OP_SELLSTOP;
				isFilled = orderType == OP_BUY || orderType == OP_SELL;
				isBuy = orderType == OP_BUYSTOP || orderType == OP_BUY;
				isSell = orderType == OP_SELLSTOP || orderType == OP_SELL;
			
				//-- Detect initial close
				if(OrderParams[orderID][ORDER_STATUS] != STATUS_CLOSED)
				{
					double profit = OrderProfit();
					output_Info("orders_Update","Order CLOSED. Profit: $"+d2s(profit)+"  position="+positionID+" id="+orderID);
					OrderParams[orderID][ORDER_STATUS] = STATUS_CLOSED;
					PositionParams[positionID][POSITION_PROFITS]+=1;
					if(profit>0) sound_Play("profit.wav");
					else sound_Play("stopped.wav");
				}
			}
		}
	}
}

// Register() - Registers an order into memory. Returns order id.
//======================================================================================================================================
int orders_Register(int position, int type, double price, double stop, double profit)
{
	int id = _numOrders;
	OrderParams[id][ORDER_POSITION]  = position;
	OrderParams[id][ORDER_TYPE] 		= type;
	OrderParams[id][ORDER_PRICE] 		= price;
	OrderParams[id][ORDER_STOP] 		= stop;
	OrderParams[id][ORDER_PROFIT] 	= profit;
	OrderParams[id][ORDER_STATUS] 	= STATUS_OPEN;
	output_Debug("orders_Register","Order REGISTERED: position="+position+" id="+id+" type="+type+" price="+ds(price)+" stop="+ds(stop)+" profit="+ds(profit));

	_numOrders++;
	return(_numOrders-1);
}

// orders_Close() - Closes the currently selected order. Returns true on success.
//======================================================================================================================================
bool orders_Close(int orderID)
{
	//-- Save currently selected order
	int previousTicket = OrderTicket();
	
	//-- Find order
	for(int i=0; i < OrdersTotal(); i++)
	{
		if(OrderSelect(i, SELECT_BY_POS))
		{
			//-- Matching order found
			if(OrderMagicNumber() == orderID)
			{
				//-- Delete order
				if(OrderDelete(OrderTicket()))
				{
					output_Debug("orders_Close","CLOSED ticket: "+OrderTicket());
					OrderParams[orderID][ORDER_STATUS] = STATUS_CLOSED;
					return(true);
				}
				else
				{
					OrderParams[orderID][ORDER_STATUS]=STATUS_OPEN;
					output_Warning("orders_Close","Unable to close ticket: "+OrderTicket());
					return(false);
				}
			}
		}
	}
	
	//-- Re-select original ticket
	OrderSelect(previousTicket, SELECT_BY_TICKET);
}

// orders_Modify() - Modifies an order by ticket
//======================================================================================================================================
bool orders_Modify(int ticket, double price, double stop, double profit)
{
	if(OrderModify(ticket, price, stop, profit, 0, Orange))
	{
		output_Debug("orders_Modify","Order MODIFIED: ticket="+OrderTicket());
	}
	else
	{
		output_Error("orders_Modify","Failed to modify order: ticket="+OrderTicket());
	}
}

// orders_Breakven() - Moves an orders stop to it's entry price.
//======================================================================================================================================
bool orders_Breakeven(int orderID)
{
	//-- Save currently selected order
	int previousTicket = OrderTicket();
	
	//-- Find order
	for(int i=0; i < OrdersTotal(); i++)
	{
		if(OrderSelect(i, SELECT_BY_POS))
		{
			//-- Matching order found
			if(OrderMagicNumber() == orderID)
			{
				double open = OrderOpenPrice();
				double stop = OrderOpenPrice();
				/*
				if(CompensateSpread)
				{
					if(OrderType() == OP_BUY) stop = stop - marketinfo_GetSpread()*Point;
					else if(OrderType() == OP_SELL) stop = stop + marketinfo_GetSpread()*Point;
				}
				*/
				if(open != OrderStopLoss())
				{
					
					output_Debug("orders_Breakven","Moving order to BREAKEVEN: id="+orderID+" ticket="+OrderTicket());
					orders_Modify(OrderTicket(), open, stop, OrderTakeProfit());
				}
			}
		}
	}
	
	//-- Re-select original ticket
	OrderSelect(previousTicket, SELECT_BY_TICKET);
}

// orders_OpenPending() - Opens a single pending order. Returns order id.
//======================================================================================================================================
int orders_OpenPending(int position, double lots, double price, double stop, double profit)
{
	//-- Initialize flags
	int type;
	
	//-- Determine direction and direction specifics
	if(stop < price)
	{
		type = OP_BUYSTOP;
		if(CompensateSpread) {
			price += marketinfo_GetSpread()*Point;
		}
	}
	else
	{
		type = OP_SELLSTOP;
		if(CompensateSpread) {
			stop   += marketinfo_GetSpread()*Point;
			profit += marketinfo_GetSpread()*Point;
		}
	}
	
	//-- Send order
	output_Debug("orders_OpenPending","SENDING pending order...  lots="+d2s(lots)+" type="+type+" price="+ds(price)+" stop="+ds(stop)+" profit="+ds(profit));
   int ticket = OrderSend(Symbol(), type, lots, price, Slippage, stop, profit, SessionID, _numOrders, 0, COLOR_PENDING);
   
   //-- Register order
   if(ticket != -1)
   {
   	int id = orders_Register(position, type, price, stop, profit);
   	return(id);
   }
   else
   {
   	output_Error("orders_OpenPending","Failed to open pending order! error="+GetLastError());
   	return(-1);
   }
}

// orders_OpenSimulated() - Opens a single simulated pending order. Returns order id.
//======================================================================================================================================
int orders_OpenSimulated()
{
}

// orders_OpenPending() - Opens a single market order. Returns order id.
//======================================================================================================================================
int orders_OpenMarket()
{
}


//+------------------------------------------------------------------+
//|                                           #motion2_positions.mq4 |
//|                                    Copyright © 2009, Dylan Heyes |
//|                                              www.octadecimal.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Dylan Heyes"
#property link      "www.octadecimal.com"


// Variables
//======================================================================================================================================
int	 _numPositions=0;


// Initialize()
//======================================================================================================================================
void positions_Initialize()
{
}

// Update() - Main positions update thread.
//======================================================================================================================================
void positions_Update()
{
	int fibID, order1, order2;
	string fibName;
	
	//-- Loop through all positions
	for(int i=0; i < _numPositions; i++)
	{
		//-- Handle open/filled positions
		if(PositionParams[i][POSITION_STATUS] != STATUS_CLOSED)
		{
			//-- Retrieve position params
			fibID = PositionParams[i][POSITION_FIB];
			fibName = FibNames[fibID];
		
			//-- Remove position if fib deleted
			if(ObjectFind(fibName)==-1 && PositionParams[i][POSITION_STATUS] == STATUS_OPEN) 
			{
				output_Debug("positions_Update","Order fib found to be deleted, REMOVING position...");
				positions_Close(i);
			}
			
			//-- Open position (pending)
			if(PositionParams[i][POSITION_STATUS] == STATUS_OPEN)
			{
				//-- Detect initial full fill
				order1 = PositionParams[i][POSITION_ORDER1];
				order2 = PositionParams[i][POSITION_ORDER2];
				if(OrderParams[order1][ORDER_STATUS] == STATUS_FILLED && OrderParams[order2][ORDER_STATUS] == STATUS_FILLED)
				{
					output_Info("positions_Update","Position fully FILLED: id="+i);
					PositionParams[i][POSITION_STATUS] = STATUS_FILLED;
					sound_Play("filled.wav");
				}
				
				//-- Detect level change
				else if(FibParams[fibID][FIB_LEVELCHANGE]==1)
				{
					// Reverse long to short
					if(PositionParams[i][POSITION_DIRECTION] == DIRECTION_LONG && FibParams[fibID][FIB_LEVEL] == FIBLVL_SHORT)
					{
						positions_Reverse(i, DIRECTION_SHORT);
					}
					// Reverse short to long
					if(PositionParams[i][POSITION_DIRECTION] == DIRECTION_SHORT && FibParams[fibID][FIB_LEVEL] == FIBLVL_LONG)
					{
						positions_Reverse(i, DIRECTION_LONG);
					}
				}
			}
			
			//-- Filled positions
			if(PositionParams[i][POSITION_STATUS] == STATUS_FILLED)
			{
				//-- Detect initial full close
				order1 = PositionParams[i][POSITION_ORDER1];
				order2 = PositionParams[i][POSITION_ORDER2];
				if(OrderParams[order1][ORDER_STATUS] == STATUS_CLOSED && OrderParams[order2][ORDER_STATUS] == STATUS_CLOSED)
				{
					output_Info("positions_Update","Position fully CLOSED: id="+i);
					PositionParams[i][POSITION_STATUS] = STATUS_CLOSED;
					fibonaccis_Remove(PositionParams[i][POSITION_FIB]);
				}
				
				//-- Detect first profit
				if(PositionParams[i][POSITION_PROFITS] == 1)
				{
					//-- Set remaining orders to breakeven
					orders_Breakeven(order2);
				}
			}
		}
	}
}

// Register() - Registers a position into memory. Returns position id.
//======================================================================================================================================
int positions_Register(int fib, int direction, int order1, int order2)
{
	int id = _numPositions;
	PositionParams[id][POSITION_FIB] 		= fib;
	PositionParams[id][POSITION_ORDER1] 	= order1;
	PositionParams[id][POSITION_ORDER2] 	= order2;
	PositionParams[id][POSITION_STATUS] 	= STATUS_OPEN;
	PositionParams[id][POSITION_DIRECTION] = direction;
	PositionParams[id][POSITION_PROFITS] 	= 0;
	output_Debug("positions_Register","Position REGISTERED: id="+id+" direction="+direction+" fib="+fib+" order1="+order1+" order2="+order2);

	_numPositions++;
	return(_numPositions-1);
}

// positions_Close() - Closes a position and any associated orders. Returns true on success.
//======================================================================================================================================
bool positions_Close(int id)
{
	output_Info("positions_Close","REMOVING position: id="+id);
	
	//-- Close order1
	if(orders_Close(PositionParams[id][POSITION_ORDER1]))
	{
		//-- Close order2
		if(orders_Close(PositionParams[id][POSITION_ORDER2]))
		{
			PositionParams[id][POSITION_STATUS] = STATUS_CLOSED;
			fibonaccis_Remove(PositionParams[id][POSITION_FIB]);
			output_Info("positions_Close","Position REMOVED successfully: id="+id);
			sound_Play("closed.wav");
			return(true);
		}
		else output_Error("positions_Close","Error removing position order 2: positionID="+id+" orderID="+PositionParams[id][POSITION_ORDER2]);
	}
	else output_Error("positions_Close","Error removing position order 1: positionID="+id+" orderID="+PositionParams[id][POSITION_ORDER1]);
	return(false);
}

// positions_CloseAll() - Closes ALL positions and any associated orders. Returns true on success.
//======================================================================================================================================
bool positions_CloseAll()
{
	return(true);
}

// positions_Reverse() - Reverses passed position and any associated orders. Returns true on success.
//======================================================================================================================================
bool positions_Reverse(int id, int direction)
{
	output_Info("positions_Reverse","REVERSING position: id="+id);
	
	//-- Close position
	positions_Close(id);
	
	//-- Open new opposite position
	positions_OpenFromFib(PositionParams[id][POSITION_FIB]);
	sound_Play("reversed.wav");
	
	
	return(true);
}

// positions_Open() - Opens a position.
//======================================================================================================================================
int positions_Open(double priceHigh, double priceLow)
{
	//-- Determine direction
	//if(priceL
}

// positions_OpenFromFib() - Opens a new fib based on the passed fib values. Returns position id.
//======================================================================================================================================
int positions_OpenFromFib(int inputFib)
{
	//-- Retrieve fib price level from input fib
	int fibLevel = FibParams[inputFib][FIB_LEVEL];
	
	//-- Ensure within valid fib bounds
	if(fibLevel == FIBLVL_OVER || fibLevel == FIBLVL_UNDER)
	{
		output_Error("positions_OpenFromFib", "Attempted to open position while out of valid level bounds: fibLevel="+fibLevel, true);
		sound_Play("outofbounds.wav");
		return(-1);
	}
	
	//-- Determine direction
	int direction;
	if(fibLevel == FIBLVL_LONG) direction = DIRECTION_LONG;
	else direction = DIRECTION_SHORT;
	output_Info("positions_OpenFromFib","OPENING POSITION from fib. fib="+inputFib+" direction="+fibLevel);

	//-- Create order fib from passed fib
	string name = NAME_PREFIX+"orderFib_"+_numOrders;
	int time1 = FibParams[inputFib][FIB_TIME1];
	int time2 = FibParams[inputFib][FIB_TIME2];
	double price1 = FibParams[inputFib][FIB_PRICE1];
	double price2 = FibParams[inputFib][FIB_PRICE2];
	int orderFib = fibonaccis_Create(FIBTYPE_ORDER, name, time1, price1, time2, price2, direction);
	
	//-- Ensure fib created successfully
	if(orderFib==-1)
	{
		output_Error("positions_OpenFromFib", "Attempted to open position from a non-existant fib: fibID="+orderFib+" name="+name);
		return(-1);
	}
	
	//-- Set direction-specific values
	double price, stop, profit1, profit2;
	if(direction == DIRECTION_LONG)
	{
		// Long
		price   = FibParams[orderFib][FIB_BUYPRICE];
		stop    = FibParams[orderFib][FIB_SELLPRICE];
		profit1 = FibParams[orderFib][FIB_PROFIT1L];
		profit2 = FibParams[orderFib][FIB_PROFIT2L];
	}
	else
	{
		// Short
		price   = FibParams[orderFib][FIB_SELLPRICE];
		stop    = FibParams[orderFib][FIB_BUYPRICE];
		profit1 = FibParams[orderFib][FIB_PROFIT1S];
		profit2 = FibParams[orderFib][FIB_PROFIT2S];
	}
	
	//-- Adjust lots to risk
	double lots1,lots2;
	double lots = utils_GetLotsByRisk(0.02, MathAbs(stop-price)/Point);
	
	//-- Distribute lots, accounting for odd amounts
	int lotsInt = lots * 100;
	if(lotsInt%2==1)
	{
		lots1 = ((lots*100)-1)*CloseLots1/100;
		lots2 = ((lots*100)+1)*CloseLots2/100;
	}
	else
	{
		lots1 = lots*CloseLots1;
		lots2 = lots*CloseLots2;
	}
	
	//-- Open orders
	int order1, order2;
	order1 = orders_OpenPending(_numPositions, lots1, price, stop, profit1);
	if(order1 >= -1) order2 = orders_OpenPending(_numPositions, lots2, price, stop, profit2);
	
	//-- Register position
	if(order1 != -1 && order2 != -1)
	{
		int id = positions_Register(orderFib, direction, order1, order2);
		sound_Play("pending.wav");
		return(id);
	}
	else 
	{
		fibonaccis_Remove(orderFib);
		return(-1);
	}
}


//+------------------------------------------------------------------+
//|                                          #motion2_fibonaccis.mq4 |
//|                                    Copyright © 2009, Dylan Heyes |
//|                                              www.octadecimal.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Dylan Heyes"
#property link      "www.octadecimal.com"

// Variables
//======================================================================================================================================
double _numFibs=0;


// Initialize() - 
//======================================================================================================================================
void fibonaccis_Initialize()
{
	//-- Create main control fib
	ControlFib = NAME_PREFIX+"ControlFib";
	ControlFibID = fibonaccis_Create(FIBTYPE_CONTROL, ControlFib, Time[0], High[0], Time[4], Low[4]);
}

// Update() - Main fibonaccis update thread.
//======================================================================================================================================
void fibonaccis_Update()
{
	//-- Redraw ControlFib from memory if deleted
	if(ObjectFind(ControlFib)<0) { 
		fibonaccis_Draw(FIBTYPE_CONTROL, ControlFib, FibParams[ControlFibID][FIB_TIME1], FibParams[ControlFibID][FIB_PRICE1], FibParams[ControlFibID][FIB_TIME2], FibParams[ControlFibID][FIB_PRICE2]);
		fibonaccis_OnFibChange(ControlFibID);
	}
	
	//-- Loop through all fibs
	for(int i=0; i < _numFibs; i++)
	{
		//-- Get name
		string name = FibNames[i];
		
		//-- Save last prices
		FibParams[i][FIB_PRICE1LAST] = FibParams[i][FIB_PRICE1];
		FibParams[i][FIB_PRICE2LAST] = FibParams[i][FIB_PRICE2];
		
		//-- Get current prices
		FibParams[i][FIB_PRICE1] = ObjectGet(name, OBJPROP_PRICE1);
		FibParams[i][FIB_PRICE2] = ObjectGet(name, OBJPROP_PRICE2);
		
		//-- Detect price level change
		int level = GetCurrentPriceLevel(i);
		if(level != FibParams[i][FIB_LEVEL]) fibonaccis_OnPriceLevelChange(i, level);
		else FibParams[i][FIB_LEVELCHANGE] = 0;
		
		//-- Detect fib price change
		if(FibParams[i][FIB_PRICE1] != FibParams[i][FIB_PRICE1LAST] || FibParams[i][FIB_PRICE2] != FibParams[i][FIB_PRICE2LAST])
		{
			//-- Flag as timeout and reset time
			FibParams[i][FIB_TIMEOUT] = 1;
			FibParams[i][FIB_TIMEOUTTIME] = 0;
		}
		
		//-- Detect timeout complete
		if(FibParams[i][FIB_TIMEOUT] == 1)
		{
			//-- Set initial timeout color
			if(FibParams[i][FIB_TIMEOUTTIME] == 0)
			{
				//-- Set timeout color
				ObjectSet(name, OBJPROP_COLOR, FIBCOLOR_TIMEOUT);
				fibonaccis_SetColor(i, FIBCOLOR_NORMAL);
				gui_Refresh();
			}
			//-- Timeout complete
			if(FibParams[i][FIB_TIMEOUTTIME] >= FibTimeout)
			{
				//-- Unset change flag and dispatch change
				FibParams[i][FIB_TIMEOUT] = 0;
				fibonaccis_OnFibChange(i);
			
				//-- Unset timeout color
				ObjectSet(name, OBJPROP_COLOR, FIBCOLOR_NORMAL);
				gui_Refresh();
				
			}
			else FibParams[i][FIB_TIMEOUTTIME]+=1;
		}
	}
}

// fibonaccis_OnFibChange() - Called when a fibonacci has changed.
//======================================================================================================================================
int fibonaccis_OnFibChange(int id)
{
	//-- Get fib name
	string name = FibNames[id];

	//-- Copy new values
   double price1 = d(ObjectGet(name, OBJPROP_PRICE1)); 
   double price2 = d(ObjectGet(name, OBJPROP_PRICE2));
   double range = d(price1 - price2);
   FibParams[id][FIB_TIME1]     = ObjectGet(name, OBJPROP_TIME1);
   FibParams[id][FIB_TIME2]     = ObjectGet(name, OBJPROP_TIME2);
   FibParams[id][FIB_RANGE]     = range;
   FibParams[id][FIB_BUYPRICE]  = d(price1 + (range * FibEntryThreshold)/* + marketinfo_GetSpread()*/);
   FibParams[id][FIB_SELLPRICE] = d(price2 - (range * FibEntryThreshold));
   FibParams[id][FIB_PROFIT1L]  = d(price1 + (range * ProfitLevel1));
   FibParams[id][FIB_PROFIT2L]  = d(price1 + (range * ProfitLevel2));
   FibParams[id][FIB_PROFIT1S]  = d(price2 - (range * ProfitLevel1));
   FibParams[id][FIB_PROFIT2S]  = d(price2 - (range * ProfitLevel2));
   //output_Trace("fibonaccis_OnFibChange","Fib changed: id="+id+" name="+name);
		
	//-- Get outcome
	int outcome = fibonaccis_GetOutcome(id);
	if(outcome==-1) fibonaccis_SetColor(id, FIBCOLOR_STOPPED);
	if(outcome==0)  fibonaccis_SetColor(id, FIBCOLOR_NORMAL);
	if(outcome==1)  fibonaccis_SetColor(id, FIBCOLOR_PROFIT1);
	if(outcome==2)  fibonaccis_SetColor(id, FIBCOLOR_PROFIT2);
}

// fibonaccis_OnPriceLevelChange() - Dispatched when the price level has changed relative to the passed fib.
//======================================================================================================================================
int fibonaccis_OnPriceLevelChange(int id, int level)
{
	//output_Trace("fibonaccis_OnPriceLevelChange","Price level changed: id="+id+" level="+level);
	
	//-- Set change flag
	FibParams[id][FIB_LEVELCHANGE] = 1;
	
	//-- Lookup name
	string name = FibNames[id];
	
	//-- Save new level
	FibParams[id][FIB_LEVEL] = level;
	
	//-- Set level specific values
	if(level == FIBLVL_LONG)
	{
      ObjectSetFiboDescription(name, 2, "S %$");
      ObjectSetFiboDescription(name, 5, "->LONG %$");
   }
   else if(level == FIBLVL_SHORT)
   {
   	ObjectSetFiboDescription(name, 2, "->SHORT %$");
      ObjectSetFiboDescription(name, 5, "L %$");
   }
   else
   {
   	ObjectSetFiboDescription(name, 2, "S %$");
      ObjectSetFiboDescription(name, 5, "L %$");
   }
   
   //-- Flag refresh
   gui_Refresh();
}

// Register() - Registers a fibonacci.
//======================================================================================================================================
int fibonaccis_Register(string name)
{
	int id = _numFibs;
	FibNames[id] = name;
	FibParams[id][FIB_TIMEOUT]	  = 0;
	FibParams[id][FIB_TIMEOUTTIME] = 0;
   output_Debug("fibonaccis_Register","Fib REGISTERED: id="+id+" name="+name);

	// Postprocess and return
	_numFibs++;
	return(_numFibs-1);
}

// Draw() - Draws a fibonacci.
//======================================================================================================================================
void fibonaccis_Draw(int fibType, string name, int time1, double price1, int time2, double price2, int directionFilter=DIRECTION_FLAT)
{
	if(ObjectCreate(name, OBJ_FIBO, 0, time1, price1, time2, price2)) 
	{
		ObjectSet(name, OBJPROP_FIBOLEVELS, 8);
		if(directionFilter != DIRECTION_LONG)
		{
      	ObjectSet(name, OBJPROP_FIRSTLEVEL,   -ProfitLevel2);
      	ObjectSetFiboDescription(name, 0, "p2  %$");
      	ObjectSet(name, OBJPROP_FIRSTLEVEL+1, -ProfitLevel1);
      	ObjectSetFiboDescription(name, 1, "p1  %$");
      	ObjectSet(name, OBJPROP_FIRSTLEVEL+2, 0 - FibEntryThreshold);
      }
      if(directionFilter != DIRECTION_SHORT)
      {
      	ObjectSet(name, OBJPROP_FIRSTLEVEL+6,  1 + ProfitLevel1);
      	ObjectSetFiboDescription(name, 6, "p1  %$");
      	ObjectSet(name, OBJPROP_FIRSTLEVEL+7,  1 + ProfitLevel2);
      	ObjectSetFiboDescription(name, 7, "p2  %$");
      }
      ObjectSetFiboDescription(name, 2, "S %$");
      ObjectSet(name, OBJPROP_FIRSTLEVEL+3,  0.0);
      ObjectSet(name, OBJPROP_FIRSTLEVEL+4,  1.0);
      ObjectSet(name, OBJPROP_FIRSTLEVEL+5,  1 + FibEntryThreshold);
      ObjectSetFiboDescription(name, 5, "L %$");
      
      if(fibType == FIBTYPE_CONTROL)
      {
      	ObjectSet(name, OBJPROP_COLOR, White);
      	ObjectSet(name, OBJPROP_LEVELCOLOR, FIBCOLOR_NORMAL);
      	ObjectSet(name, OBJPROP_RAY, 0);
      	ObjectSet(name, OBJPROP_WIDTH, 1);
      	ObjectSet(name, OBJPROP_BACK, 0);
      }
      else
      {
      	ObjectSet(name, OBJPROP_COLOR, 0xFF0000);
      	ObjectSet(name, OBJPROP_LEVELCOLOR, 0xFF0000);
      	ObjectSet(name, OBJPROP_RAY, 0);
      	ObjectSet(name, OBJPROP_WIDTH, 5);
      	ObjectSet(name, OBJPROP_BACK, 1);
      }
      
		output_Trace("fibonaccis_Draw","Fibonacci DRAWN: "+name);
      gui_Refresh();
      return(0);
	}
	else
	{
		output_Error("fibonaccis_Draw","Unable to draw fibonacci: "+name);
		return(-1);
	}
}

// Create() - Registers and draws a fibonacci.
//======================================================================================================================================
int fibonaccis_Create(int fibType, string name, int time1, double price1, int time2, double price2, int directionFilter=DIRECTION_FLAT)
{
	output_Debug("fibonaccis_Create","Creating fib: name="+name+" time1="+time1+" time2="+time2+" price1="+ds(price1)+" price2="+ds(price2)+" directionFilter="+directionFilter);
	
	if(ObjectFind(name)<0) fibonaccis_Draw(fibType, name, time1, price1, time2, price2, directionFilter); 
	else output_Debug("fibonaccis_Create","Registering EXISTING fibonacci: "+name);
	
	int id = fibonaccis_Register(name);
	fibonaccis_OnFibChange(id);
	return(id);
}

// fibonaccis_Remove() - Registers a fibonacci.
//======================================================================================================================================
int fibonaccis_Remove(int id)
{
	string name = FibNames[id];
	if(ObjectFind(name)>-1)
	{
		if(ObjectDelete(name))
		{
			output_Debug("fibonaccis_Remove","Fib REMOVED: id="+id+" name="+name);
			return(0);
		}
		else
		{
			output_Warning("fibonaccis_Remove","Failed to delete fib: id="+id+" name="+name);
			return(-1);
		}
	}
	else return(-1);
}

// fibonaccis_SetColor() - Sets the fib color.
//======================================================================================================================================
int fibonaccis_SetColor(int id, int clr)
{
	string name = FibNames[id];
	if(ObjectFind(name)>-1) {
		ObjectSet(name, OBJPROP_LEVELCOLOR, clr);
		gui_Refresh();
	}
}

// fibonaccis_MoveControlFib() - Moves the control fib to a new location and updates any values and properties.
//======================================================================================================================================
int fibonaccis_MoveControlFib(int time1, double price1, int time2, double price2)
{
	if(ObjectFind(ControlFib)>-1) 
	{
		//-- Move
		ObjectSet(ControlFib, OBJPROP_TIME1, time1);   ObjectSet(ControlFib, OBJPROP_TIME2, time2);
		ObjectSet(ControlFib, OBJPROP_PRICE1, price1); ObjectSet(ControlFib, OBJPROP_PRICE2, price2);
		
		//-- Force redraw
		gui_Refresh();
	}
	else output_Warning("fibonaccis_MoveControlFib","Attempted to move ControlFib, but fib was not found: "+ControlFib);
}

// fibonaccis_GetOutcome() - Determines the outcome of the passed fib.
//======================================================================================================================================
int fibonaccis_GetOutcome(int id)
{
	string name = FibNames[id];
	
	if(ObjectFind(name) > -1) 
	{
		// initialize flags
		int direction = DIRECTION_FLAT;
		bool profit1=false;
		
		// use newer fib time
		int time = MathMax(ObjectGet(name, OBJPROP_TIME1),ObjectGet(name, OBJPROP_TIME2));
		int startBar = utils_GetBarByTime(time);
		
		// loop through bars from oldest to newest
		for(int i=startBar; i >= 0; i--)
		{
			if(direction == DIRECTION_FLAT)
			{
				if(High[i] >= FibParams[id][FIB_BUYPRICE]) direction = DIRECTION_LONG; 
				else if(Low[i] <= FibParams[id][FIB_SELLPRICE]) direction = DIRECTION_SHORT;
			}
			else if(direction == DIRECTION_LONG)
			{
				if(Low[i] <= FibParams[id][FIB_SELLPRICE]) {
					return(-1);
				}
				else if(!profit1) {
					if(High[i] >= FibParams[id][FIB_PROFIT1L]) profit1 = true;
				}
				else {
					if(High[i] >= FibParams[id][FIB_PROFIT2L]) return(2);
					else if(Low[i] <= FibParams[id][FIB_PRICE1]) break;
				}
			}
			else if(direction == DIRECTION_SHORT)
			{
				if(High[i] >= FibParams[id][FIB_BUYPRICE]) {
					return(-1);
				}
				else if(!profit1) {
					if(Low[i] <= FibParams[id][FIB_PROFIT1S]) profit1 = true;
				}
				else {
					if(Low[i] <= FibParams[id][FIB_PROFIT2S]) return(2);
					else if(High[i] >= FibParams[id][FIB_PRICE2]) break;
				}
			}
		}
		
		// return 1 if profit1 was reached, else return 0
		if(profit1) return(1);
		else return(0);
	}
	else output_Debug("fibonaccis_GetOutcome","Tried to determine outcome of a nonexistant fib: id="+id+" name="+name);
}

// GetCurrentPriceLevel() - Returns the current fib level relative to the current price.
//======================================================================================================================================
int GetCurrentPriceLevel(int id)
{
	double fibBuy = FibParams[id][FIB_BUYPRICE];
	double fibSell = FibParams[id][FIB_SELLPRICE];
	double fibRange = FibParams[id][FIB_RANGE];
	
   if(Bid >= fibBuy) return(FIBLVL_OVER);
   else if(Bid >= fibSell + (fibRange * MathMax(0.55, 0.50))) return(FIBLVL_LONG);
   else if(Bid >= fibSell + (fibRange * MathMin(0.45, 0.50))) return(FIBLVL_MID);
   else if(Bid >= fibSell) return(FIBLVL_SHORT);
   else return(FIBLVL_UNDER);
}



//+------------------------------------------------------------------+
//|                                            #motion2_fractals.mq4 |
//|                                    Copyright © 2009, Dylan Heyes |
//|                                              www.octadecimal.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Dylan Heyes"
#property link      "www.octadecimal.com"

#define FRACTAL_NEXT 0
#define FRACTAL_LAST 1
#define MODE_BOTH 	2

// Private 
//======================================================================================================================================
int _fractalLow, _fractalHigh, _fractalPointer=0;
int _latestFractalLow, _latestFractalHigh;
int _latestFractalLowLast, _latestFractalHighLast;


// Initialize() - 
//======================================================================================================================================
void fractals_Initialize()
{
	//-- Select two most recent fractals
	fractals_SelectFractal(FRACTAL_LAST);
	fractals_SelectFractal(FRACTAL_LAST);
}

// BarOpen() - Called via main each bar open. Used to shift fractal times to compensate for change in time.
//======================================================================================================================================
void fractals_BarOpen()
{
	//-- Compensate for time change
	_fractalLow++; _fractalHigh++; _fractalPointer++;
	_latestFractalLow++; _latestFractalHigh++;
	_latestFractalLowLast++; _latestFractalHighLast++;
}

// Update() - Main fractals update thread.
//======================================================================================================================================
void fractals_Update()
{
	//-- Save last
	_latestFractalLowLast  = _latestFractalLow;
	_latestFractalHighLast = _latestFractalHigh;
	
	//-- Save new
	_latestFractalLow  = fractals_GetLastFractal(MODE_LOWER);
	_latestFractalHigh = fractals_GetLastFractal(MODE_UPPER);
	
	//-- Override new fractal if AllowOlderFractals is false (fractal disappeared)
	if(!AllowOlderFractals)
	{
		if(_latestFractalLow > _latestFractalLowLast) _latestFractalLow = _latestFractalLowLast;
		if(_latestFractalHigh > _latestFractalHighLast) _latestFractalHigh = _latestFractalHighLast;
	}
	
	//-- Detect change
	if(_latestFractalLow != _latestFractalLowLast && _latestFractalHigh != _latestFractalHighLast)
		fractals_OnFractalChange(MODE_BOTH);
	else if(_latestFractalHigh != _latestFractalHighLast)
		fractals_OnFractalChange(MODE_UPPER);
	else if(_latestFractalLow != _latestFractalLowLast)
		fractals_OnFractalChange(MODE_LOWER);
	
}

// fractals_OnFractalChange() - Called when a change in the most recent fractals detected.
//======================================================================================================================================
void fractals_OnFractalChange(int mode)
{
	if(states_GetDrawingState()==DRAWING_AUTO) fibonaccis_MoveControlFib(Time[_latestFractalHigh], High[_latestFractalHigh], Time[_latestFractalLow], Low[_latestFractalLow]);
	if(states_GetControlState()==CONTROL_AUTO) positions_OpenFromFib(ControlFibID);
	sound_Play("fractal.wav");
}

// fractals_GetLastFractal() - Returns the bar time of the most recent fractal.
//======================================================================================================================================
int fractals_GetLastFractal(int mode)
{
	for(int i=FractalLookback; i < Bars; i++)
		if(iFractals(NULL, 0, mode, i) > 0) return(i);
	return(-1);
}

// fractals_Select() - Selects the last/next fractal pair, relative to current fractal pointer.
//======================================================================================================================================
void fractals_SelectFractal(int dir)
{
	//output_Trace("fractals_SelectLastFractal","Selecting last fractal from current position: "+_fractalPointer);
	int low, high;
	for(int i=0; i < 50; i++)
	{
		//-- Get fractal values at _fractalPointer
		high = iFractals(NULL, 0, MODE_UPPER, _fractalPointer);
		low  = iFractals(NULL, 0, MODE_LOWER, _fractalPointer);
		
		//-- Set new values if not 0
		if(low > 0)  _fractalLow  = _fractalPointer;
		if(high > 0) _fractalHigh = _fractalPointer;
		
		//-- Move pointer
		if(dir==FRACTAL_LAST) _fractalPointer++;
		else if(dir==FRACTAL_NEXT && _fractalPointer > 0) _fractalPointer--;
		
		//-- Return if found
		if(high!=0 || low!=0) return;
		
		//-- Error check
		if(i>=49) output_Warning("fractals_SelectLastFractal", "Reached end when searching for fractal. pointer="+_fractalPointer);
	}
}
void fractals_SelectNextFractal()
{
	
}

// Fractal getters
//======================================================================================================================================
int fractals_GetFractalHigh()
{
	return(_fractalHigh);
}
int fractals_GetFractalLow()
{
	return(_fractalLow);	
}
int fractals_GetLatestFractalHigh()
{
	return(_latestFractalHigh);
}
int fractals_GetLatestFractalLow()
{
	return(_latestFractalLow);	
}


//+------------------------------------------------------------------+
//|                                                 #motion2_gui.mq4 |
//|                                    Copyright © 2009, Dylan Heyes |
//|                                              www.octadecimal.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Dylan Heyes"
#property link      "www.octadecimal.com"

// Variables
//======================================================================================================================================
bool _needsRefresh=false;


// gui_Initialize() - 
//======================================================================================================================================
void gui_Initialize()
{
   output_Info("gui_Initialize", "Initializing GUI...");
   
	//-- Create widgets
   CreateDirectionSwitch();
   CreateControlSwitch();
   CreateDrawingSwitch();
   
   //-- Force widget refresh
   widgets_Update();
   
   //-- Set initial states
   states_SetSwitchState(directionSwitch, DirectionState);
   states_SetSwitchState(controlSwitch, ControlState);
   states_SetSwitchState(drawingSwitch, DrawingState);
}

// gui_Update() - Main GUI update thread.
//======================================================================================================================================
void gui_Update()
{
	//-- Refresh
	if(_needsRefresh) WindowRedraw();
	_needsRefresh=false;
}

// gui_Refresh() - Marks the GUI as refresh needed.
//======================================================================================================================================
void gui_Refresh()
{
	_needsRefresh=true;
}

// Widget creation (Switches)
//======================================================================================================================================
void CreateDirectionSwitch()
{
   double statesD[3,3];

   // Long
   statesD[0][STATE_LABEL] = states_CreateStateLabel("Long");
   statesD[0][STATE_INACTIVE_CLR] = COLOR_INACTIVE;
   statesD[0][STATE_ACTIVE_CLR] = COLOR_GREEN;
   
   // Flat
   statesD[1][STATE_LABEL] = states_CreateStateLabel("Flat");
   statesD[1][STATE_INACTIVE_CLR] = COLOR_INACTIVE;
   statesD[1][STATE_ACTIVE_CLR] = COLOR_ACTIVE;
   
   // Short
   statesD[2][STATE_LABEL] = states_CreateStateLabel("Short");
   statesD[2][STATE_INACTIVE_CLR] = COLOR_INACTIVE;
   statesD[2][STATE_ACTIVE_CLR] = COLOR_RED;
   
   directionSwitch = widgets_CreateSwitch("directionSwitch", statesD, 3, 6);
}
void CreateControlSwitch()
{
   double statesC[3,3];

   // Off
   statesC[0][STATE_LABEL] = states_CreateStateLabel("Off");
   statesC[0][STATE_INACTIVE_CLR] = COLOR_INACTIVE;
   statesC[0][STATE_ACTIVE_CLR] = COLOR_RED;
   
   // Manual
   statesC[1][STATE_LABEL] = states_CreateStateLabel("Manual");
   statesC[1][STATE_INACTIVE_CLR] = COLOR_INACTIVE;
   statesC[1][STATE_ACTIVE_CLR] = COLOR_ACTIVE;
   
   // Auto
   statesC[2][STATE_LABEL] = states_CreateStateLabel("Auto");
   statesC[2][STATE_INACTIVE_CLR] = COLOR_INACTIVE;
   statesC[2][STATE_ACTIVE_CLR] = COLOR_GREEN;
   
   controlSwitch = widgets_CreateSwitch("controlSwitch", statesC, 3, 6);
}
void CreateDrawingSwitch()
{
   double statesA[3,3];

   // Manual
   statesA[0][STATE_LABEL] = states_CreateStateLabel("Off");
   statesA[0][STATE_INACTIVE_CLR] = COLOR_INACTIVE;
   statesA[0][STATE_ACTIVE_CLR] = COLOR_ACTIVE;
   
   // Auto
   statesA[1][STATE_LABEL] = states_CreateStateLabel("User");
   statesA[1][STATE_INACTIVE_CLR] = COLOR_INACTIVE;
   statesA[1][STATE_ACTIVE_CLR] = COLOR_ACTIVE;
   
   // Redraw
   statesA[2][STATE_LABEL] = states_CreateStateLabel("Redraw");
   statesA[2][STATE_INACTIVE_CLR] = COLOR_INACTIVE;
   statesA[2][STATE_ACTIVE_CLR] = COLOR_ACTIVE;
   
   drawingSwitch = widgets_CreateSwitch("drawingSwitch", statesA, 3, 6);
}



//+------------------------------------------------------------------+
//|                                             #motion2_objects.mq4 |
//|                                    Copyright © 2009, Dylan Heyes |
//|                                              www.octadecimal.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Dylan Heyes"
#property link      "www.octadecimal.com"

//-- Private
int    _numObjects = 0, _numStrings = 0;	// Counts
string _objNames[20];                  	// Object id|name
string _objStrings[20];                 	// Label strings
double _objParams[20, 10];             	// Object params



// Initialize() - 
//======================================================================================================================================
void objects_Initialize()
{
	
}

// Update() - Objects update thread.
//======================================================================================================================================
void objects_Update()
{
	//-- Loop through all objects
	for(int i=0; i < _numObjects; i++)
   {
   	//-- Get object name
      string name = _objNames[i];
      
      //-- Check if object does NOT exist
      if(ObjectFind(name) == -1)
      {
      	//-- Get object params
         int x = _objParams[i][OBJ_X];
         int y = _objParams[i][OBJ_Y];
         int w = _objParams[i][OBJ_W];
         int h = _objParams[i][OBJ_H];
         int clr = _objParams[i][OBJ_CLR];
         int type = _objParams[i][OBJ_TYPE];
         int stringID = _objParams[i][OBJ_STRING];
         
      	//-- Redraw (and flag as redraw)
         if(type == OBJ_RECTANGLE) objects_DrawBox(name, clr, x, y, w, h); 
         else if(type == OBJ_TEXT) objects_DrawLabel(name, _objStrings[stringID], clr, x, y);
      }
   }
}

// objects_Register() - Registers an Object.
//======================================================================================================================================
int objects_Register(string name, int clr, int x, int y, int w, int h, int type, int stringID=-1)
{
   //-- Determine if object has already been registered
   int id = objects_GetIDByName(name);
   
   //-- Use next id if doesn't exist
   if(id==-1) id = _numObjects;
   
   //-- Save params
   _objNames[id] = name;
   _objParams[id][OBJ_X] = x;
   _objParams[id][OBJ_Y] = y;
   _objParams[id][OBJ_W] = w;
   _objParams[id][OBJ_H] = h;
   _objParams[id][OBJ_CLR] = clr;
   _objParams[id][OBJ_TYPE] = type;
   _objParams[id][OBJ_STRING] = stringID;
   _numObjects++;
   //output_Debug("objects_RegisterObject","Object registered: "+name+", id: "+id+" (total: "+_numObjects+")");
   return(id);
}

// objects_RegisterString() - Registers a string (label contents). Used for memory when redrawing deleted objects.
//======================================================================================================================================
int objects_RegisterString(string text)
{
   //-- Save params
   _objStrings[_numStrings] = text;
   _numStrings++;
   //output_Debug("objects_RegisterString","String registered: `"+text+"` (total: "+_numStrings+")");
   return(_numStrings-1);
}

// objects_GetIDByName() - Returns object ID if exists, else returns -1.
//======================================================================================================================================
int objects_GetIDByName(string name)
{
   for(int i = 0; i < _numObjects; i++)
      if(_objNames[i] == name) return(i);
   return(-1);
}

// objects_DrawBox() - Creates a base box, used as a building block for other widgets.
//======================================================================================================================================
void objects_DrawBox(string name, int clr, int x, int y, int w, int h)
{
   //-- Draw BOX
   output_Trace("objects_DrawBox","name="+name+" clr="+clr+" x="+x+" y="+y+" w="+w+" h="+h);
   if(ObjectCreate(name, OBJ_RECTANGLE, 1, Time[x+w], HUD_Y-y, Time[x], (HUD_Y-y)-h))
   {
      //-- Set color
      ObjectSet(name, OBJPROP_COLOR, clr);
   } 
   //-- Creation failure
   else output_Error("objects_CreateBox","Unable to create box."+" :: "+GetLastError());
}

// objects_DrawLabel() - Creates and positions a label.
//======================================================================================================================================
void objects_DrawLabel(string name, string text, int clr, int x, int y)
{
	//-- Draw LABEL
   output_Trace("objects_DrawLabel","name="+name+" clr="+clr+" x="+x+" y="+y);
   if(ObjectCreate(name, OBJ_TEXT, 1, Time[(HUD_X+x)], HUD_Y-y))
   {
      //-- Set text ("" is a hack via RedrawObjects, hehe)
      if(text != "") ObjectSetText(name, text, 8, "Arial");
      
      //-- Set color
      ObjectSet(name, OBJPROP_COLOR, clr);
   }
   //-- Creation failure
   else output_Error("objects_CreateLabel","Unable to create label: "+text+" :: "+GetLastError());
}


//+------------------------------------------------------------------+
//|                                             #motion2_widgets.mq4 |
//|                                    Copyright © 2009, Dylan Heyes |
//|                                              www.octadecimal.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Dylan Heyes"
#property link      "www.octadecimal.com"

//-- Dependencies (Pre)

//-- Widgets
int    controlSwitch, directionSwitch, drawingSwitch, cancelButton;

//-- Private (widgets)
int 	 _numSwitches=0, _numLabels=0;																// Counts
string _switchNames[WIDGETS_MAXSWITCHES];															// Switch names lookup
string _switchButtons[WIDGETS_MAXSWITCHES];														// Switch button (names) lookup
double _switchParams[WIDGETS_MAXSWITCHES, WIDGETS_NUMPARAMS];								// Switch param lookup

//-- Private (states)
string _stateLabels[WIDGETS_MAXSWITCHES, WIDGETS_MAXOPTIONS];								// Switch option lookup
int	 _stateParams[WIDGETS_MAXSWITCHES, WIDGETS_MAXOPTIONS, STATES_NUMPARAMS];		// State params lookup


// widgets_Initialize() - 
//======================================================================================================================================
void widgets_Initialize()
{
	
}

// widgets_Update() - Main GUI update thread.
//======================================================================================================================================
void widgets_Update()
{
	//-- Update objects
	objects_Update();
	
	//-- Update states
	states_Update();
}

// widgets_GetSwitchIDByName() - Returns widget ID if exists, else returns -1.
//======================================================================================================================================
int widgets_GetSwitchIDByName(string name)
{
	for(int i=0; i < _numSwitches; i++)
		if(_switchNames[i] == name) return(i);
	return(-1);
}

// widgets_RegisterSwitch() - Registers a Switch.
//======================================================================================================================================
int widgets_RegisterSwitch(string name, string button, double states[][], int x, int w, int h, int numOptions)
{
   _switchNames[_numSwitches] = name;
   _switchButtons[_numSwitches] = button;
   _switchParams[_numSwitches][SWITCH_X] = x;  // neutral x
   _switchParams[_numSwitches][SWITCH_W] = w;
   _switchParams[_numSwitches][SWITCH_H] = h;
   _switchParams[_numSwitches][SWITCH_STATE] = x;  // state
   _switchParams[_numSwitches][SWITCH_NUMOPTIONS] = numOptions;
   _switchParams[_numSwitches][SWITCH_BTNHEIGHT] = (h-(SWITCH_MARGIN*2))/numOptions;
   
   //-- Copy state (stupid mql4)
   for(int i = 0; i < numOptions; i++)
      for(int j = 0; j < ArraySize(states); j++)
         _stateParams[_numSwitches][i][j] = states[i][j];
   
   _numSwitches++;
   return(_numSwitches-1);
}

// widgets_CreateSwitch() - Creates all the objects composing of a switch.
//======================================================================================================================================
int widgets_CreateSwitch(string name, double states[][], int numOptions, int w)
{
	//-- Check if switch already exists in memory
	int id = widgets_GetSwitchIDByName(name);
	if(id > -1)
	{
		/* TODO: May need to check for individual object existance here and redraw if necessary. */
		output_Debug("widgets_CreateSwitch", "Switch already exists: `"+name+"` @ "+id);
		return(id);
	}
	
	//-- Check for max num switches
	if(_numSwitches >= WIDGETS_MAXSWITCHES) {
		output_Error("widgets_CreateSwitch","Unable to create switch, already at maximum amount ("+WIDGETS_MAXSWITCHES+")! Readjust WIDGETS_MAXSWITCHES to allocate more memory for additional switches.");
		return(-1);
	}
   else output_Debug("widgets_CreateSwitch","Creating switch: "+name+"...");
   
   //-- Prefix name
   name = NAME_PREFIX+name;

   //-- Determine x
   int x = 0;
   if(_numSwitches > 0) {
      // Get offset from last switch and add spacing
      x = _switchParams[_numSwitches-1][SWITCH_X] + _switchParams[_numSwitches-1][SWITCH_W];
      x += SWITCH_SPACING;
   }
   
   //-- Get and marginze height
   int h = HUD_Y - (SWITCH_MARGIN*2);
   
   //-- Create background
   objects_Register(name+"_background", COLOR_BACKGROUND, x, SWITCH_MARGIN, w, h, OBJ_RECTANGLE);
   
   //-- Create button
   int btnX = x + w - BUTTON_WIDTH - SWITCH_MARGIN;
   double btnHeight = (h-(SWITCH_MARGIN*2))/numOptions;
   objects_Register(name+"_button", COLOR_SWITCH, btnX, 2 * SWITCH_MARGIN, BUTTON_WIDTH, btnHeight, OBJ_RECTANGLE);
   
   //-- Create options
   for(int i = 0; i < numOptions; i++) {
      //-- Create labels
      int lblY = (btnHeight*i) + (btnHeight/2);
      int labelID = states[i][STATE_LABEL];
      int stringID = objects_RegisterString(_stateLabels[labelID][LABEL_TEXT]);
      _stateLabels[labelID][LABEL_NAME] = name+"_label"+i;
      objects_Register(name+"_label"+i, COLOR_INACTIVE, btnX - BUTTON_WIDTH - LABEL_MARGIN, lblY, 0, 0, OBJ_TEXT, stringID);
   }
   
   //-- Register switch
   id = widgets_RegisterSwitch(name, name+"_button", states, x, w, h, numOptions);
   
   return(id);
}



//+------------------------------------------------------------------+
//|                                              #motion2_states.mq4 |
//|                                    Copyright © 2009, Dylan Heyes |
//|                                              www.octadecimal.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Dylan Heyes"
#property link      "www.octadecimal.com"

int 	 _controlState, _directionState, _drawingState, _cancelState;						// State memory

// Initialize() - 
//======================================================================================================================================
void states_Initialize()
{
	
}

// Update() - Objects update thread.
//======================================================================================================================================
void states_Update()
{
	for(int i = 0; i < _numSwitches; i++)
   {
      double state = _switchParams[i][SWITCH_STATE];
      int numOptions = _switchParams[i][SWITCH_NUMOPTIONS];
      double btnHeight = _switchParams[i][SWITCH_BTNHEIGHT];
      double spanY = numOptions * btnHeight;
      double spacing = spanY/(numOptions-1);
      double price1 = ObjectGet(_switchButtons[i], OBJPROP_PRICE1);
      double price2 = ObjectGet(_switchButtons[i], OBJPROP_PRICE2);
      double priceCenter = MathAbs(price1 - price2) * 0.5;
      double button_y = price2 + priceCenter;
      
      //-- Check states
      for(int j = 0; j < numOptions; j++)
      {
         //-- If button position is in between this states bounds
         if(button_y > btnHeight * j && button_y < btnHeight * (j+1))
         {
            //-- State found (j), check for change
            if((numOptions-1)-j != state)
            {
               //-- Change exists, save new state...
               _switchParams[i][SWITCH_STATE] = (numOptions-1)-j;
               
               //-- ...and dispatch change
               states_OnStateChange(i, (numOptions-1)-j);
            }
         }
      }
   }
}

// SetSwitchState() - Changes the state for the specified switch. Change automatically detected by CheckStates next update.
//======================================================================================================================================
int states_SetSwitchState(int id, int state)
{
   state = (_switchParams[id][SWITCH_NUMOPTIONS]-1)-state;
   //_stateParams[id][SWITCH_STATE] = state;
   
   string buttonName = _switchButtons[id];
   double buttonHeight = _switchParams[id][SWITCH_BTNHEIGHT];
   
   ObjectSet(buttonName, OBJPROP_PRICE2, state * buttonHeight);
   ObjectSet(buttonName, OBJPROP_PRICE1, (state * buttonHeight) + buttonHeight);
}

// OnStateChange() - Dispatched upon any switch state change.
//======================================================================================================================================
void states_OnStateChange(int switchID, int state)
{
   //-- Get number of widget options
   int numOptions = _switchParams[switchID][SWITCH_NUMOPTIONS];
   
   //-- Loop through all options
   for(int i = 0; i < numOptions; i++)
   {
      //-- Get label index
      int labelID = _stateParams[switchID][i][STATE_LABEL];
      
      //-- Set active color if same as state
      if(i == state) ObjectSet(_stateLabels[labelID][LABEL_NAME], OBJPROP_COLOR, _stateParams[switchID][i][STATE_ACTIVE_CLR]);
      
      //-- Else set inactive color
      else  ObjectSet(_stateLabels[labelID][LABEL_NAME], OBJPROP_COLOR, _stateParams[switchID][i][STATE_INACTIVE_CLR]);
   }
   
   //-- Hard-coded calls (for convenience)
   // Direction Switch
   if(switchID == directionSwitch)
   {
      if(state == 0) _directionState = DIRECTION_LONG;
      else if(state == 1) _directionState = DIRECTION_FLAT;
      else if(state == 2) _directionState = DIRECTION_SHORT;
   }
   // Control Switch
   else if(switchID == controlSwitch)
   {
      if(state == 0) _controlState = CONTROL_OFF;
      else if(state == 1) _controlState = CONTROL_MANUAL;
      else if(state == 2) _controlState = CONTROL_AUTO;
   }
   // Drawing switch
   else if(switchID == drawingSwitch)
   {
      if(state == 0) _drawingState = DRAWING_OFF;
      else if(state == 1) _drawingState = DRAWING_USER;
      else if(state == 2) _drawingState = DRAWING_AUTO;
      
      //-- Move fib to most recent fractal
      if(state==DRAWING_AUTO) fibonaccis_MoveControlFib(Time[fractals_GetLatestFractalHigh()], High[fractals_GetLatestFractalHigh()], Time[fractals_GetLatestFractalLow()], Low[fractals_GetLatestFractalLow()]);
   }
   // Cancel Button
   else if(switchID == cancelButton)
   {
      if(state == 0) _cancelState = false;
      else if(state == 1) _cancelState = true;
      else if(state == 2) _cancelState = true;
   }
}

// CreateStateLabel() - Saves the text of a label in `_stateLabels`. Names created in CreateSwitch().
//======================================================================================================================================
int states_CreateStateLabel(string text)
{  
   _stateLabels[_numLabels][LABEL_TEXT] = text;
   _numLabels++;
   return(_numLabels-1);
}

// Getters
//======================================================================================================================================
int states_GetDirectionState()
{  
   return(_directionState);
}
int states_GetControlState()
{  
   return(_controlState);
}
int states_GetDrawingState()
{  
   return(_drawingState);
}


//+------------------------------------------------------------------+
//|                                               #motion2_chart.mq4 |
//|                                    Copyright © 2009, Dylan Heyes |
//|                                              www.octadecimal.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Dylan Heyes"
#property link      "www.octadecimal.com"

//-- Private
int _barsPerChart, _barsPerChartLast;


// chart_Initialize() - Initializes chart values
//======================================================================================================================================
void chart_Initialize()
{
   _barsPerChart = WindowBarsPerChart();
   _barsPerChartLast = _barsPerChart;
}

// chart_Update() - Initializes chart values
//======================================================================================================================================
void chart_Update()
{
   //-- Save last
   _barsPerChartLast = _barsPerChart;
   
   //-- Save new
   _barsPerChart = WindowBarsPerChart();
   
   //-- Dispatch change events
   if(chart_WindowBarsChanged() > -1)  chart_OnWindowBarsChange();
}


// chart_WindowBarsChanged() - Returns -1 if not changed, or number of bars if changed.
//======================================================================================================================================
int chart_WindowBarsChanged()
{
   if(_barsPerChart == _barsPerChartLast) return(-1);
   else return(_barsPerChart);
}

// chart_OnWindowBarsChange() - Dispatched upon a change in number of bars detected.
//======================================================================================================================================
void chart_OnWindowBarsChange()
{
   output_Trace("chart_OnWindowBarsChange", "Number of WindowBars changed: "+_barsPerChartLast+"->"+_barsPerChart);
}


//+------------------------------------------------------------------+
//|                                                #motion2_data.mq4 |
//|                                    Copyright © 2009, Dylan Heyes |
//|                                              www.octadecimal.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Dylan Heyes"
#property link      "www.octadecimal.com"


// Session
//======================================================================================================================================
string SessionID;

// Fibonacci lookup
//======================================================================================================================================
string FibNames[1024];
double FibParams[1024][19];
string ControlFib;
int 	 ControlFibID;

// Position lookup tables
//======================================================================================================================================
double PositionParams[1024][10];

// Order lookup tables
//======================================================================================================================================
double OrderParams[1024][10];


//+------------------------------------------------------------------+
//|                                            #motion2_keyboard.mq4 |
//|                                                      Dylan Heyes |
//|                                              www.octadecimal.com |
//+------------------------------------------------------------------+
#property copyright "Dylan Heyes"
#property link      "www.octadecimal.com"

#import "user32.dll"
   bool GetAsyncKeyState(int nVirtKey);
#import

#include <m2/#motion2_keyboard-enums.mqh>

// Key Bindings
//======================================================================================================================================
//-- Key: last fractal
#define key_LastFractal VK_1
bool  keyup_LastFractal=true;

//-- Key: next fractal
#define key_NextFractal VK_2
bool  keyup_NextFractal=true;

//-- Key: open position from control fib
#define key_OpenPosition VK_3
bool  keyup_OpenPosition=true;


// chart_Initialize() - Initializes chart values
//======================================================================================================================================
void keyboard_Initialize()
{
}

// chart_Update() - Initializes chart values
//======================================================================================================================================
void keyboard_Update()
{
   //-- Next fractal (detect down, detect up)
   if(keyup_NextFractal  && key_IsDown(key_NextFractal))  { keyup_NextFractal=false; }
   if(!keyup_NextFractal && !key_IsDown(key_NextFractal)) { keyup_NextFractal=true;  key_OnUp(key_NextFractal); }
   
   //-- Last fractal (detect down, detect up)
   if(keyup_LastFractal  && key_IsDown(key_LastFractal))  { keyup_LastFractal=false; }
   if(!keyup_LastFractal && !key_IsDown(key_LastFractal)) { keyup_LastFractal=true;  key_OnUp(key_LastFractal); }
   
   //-- Open position (detect down, detect up)
   if(keyup_OpenPosition  && key_IsDown(key_OpenPosition))  { keyup_OpenPosition=false; }
   if(!keyup_OpenPosition && !key_IsDown(key_OpenPosition)) { keyup_OpenPosition=true;  key_OnUp(key_OpenPosition); }
}

// keyboard_IsKeyDown() - Returns true if key is down, false if up.
//======================================================================================================================================
bool key_IsDown(int key)
{
	if (states_GetControlState() == CONTROL_OFF) return(false);
   if (GetAsyncKeyState(key)/* && GetAsyncKeyState(VK_LCONTROL)*/) return(true);
   else return(false);
}

// key_OnUp() - Called when a key is detected as up (once per down->up).
//======================================================================================================================================
void key_OnUp(int key)
{
   //output_Trace("key_OnUp","Key up: "+key);
   
   switch(key)
   {
   	case key_NextFractal:
   		onKeyUp_NextFractal();
   		break;
   	case key_LastFractal:
   		onKeyUp_LastFractal();
   		break;
   	case key_OpenPosition:
   		onKeyUp_OpenPosition();
   		break;
   	default:
   		break;
   }
}

// onKeyUp_NextFractal() - Cycles ControlFib to the next fractal.
//======================================================================================================================================
void onKeyUp_NextFractal()
{
	int h = fractals_GetFractalHigh();
	int l = fractals_GetFractalLow();
	fractals_SelectFractal(FRACTAL_NEXT);
	fibonaccis_MoveControlFib(Time[h], High[h], Time[l], Low[l]); 
}

// onKeyUp_LastFractal() - Cycles ControlFib to the last fractal.
//======================================================================================================================================
void onKeyUp_LastFractal()
{
	int h = fractals_GetFractalHigh();
	int l = fractals_GetFractalLow();
	fractals_SelectFractal(FRACTAL_LAST);
	fibonaccis_MoveControlFib(Time[h], High[h], Time[l], Low[l]); 
}

// onKeyUp_OpenPosition() - Opens a position based on ControlFib.
//======================================================================================================================================
void onKeyUp_OpenPosition()
{
	//-- Open position from control fib
	positions_OpenFromFib(ControlFibID);
}


//+------------------------------------------------------------------+
//|                                          #motion2_marketinfo.mq4 |
//|                                    Copyright © 2009, Dylan Heyes |
//|                                              www.octadecimal.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Dylan Heyes"
#property link      "www.octadecimal.com"

//-- Private
int _period, _spread, _digits, _tradeAllowed;
double _stopLevel, _lotSize, _minLots, _maxLots;
int _periodLast, _spreadLast, _tradeAllowedLast;


// marketinfo_Initialize() - Retrieves static market information.
//======================================================================================================================================
void marketinfo_Initialize()
{
   string s = Symbol();
   _period = Period();
   _spread = MarketInfo(s, MODE_SPREAD);
   _tradeAllowed = MarketInfo(s, MODE_TRADEALLOWED);
   _stopLevel = MarketInfo(s, MODE_STOPLEVEL);
   _lotSize = MarketInfo(s, MODE_LOTSIZE);
   _minLots = MarketInfo(s, MODE_MINLOT);
   _maxLots = MarketInfo(s, MODE_MAXLOT);
   output_Debug("marketinfo_Initialize","Lot sizes: size=$"+d2s(_lotSize)+" min="+d2s(_minLots)+" max="+d2s(_maxLots));
   output_Debug("marketinfo_Initialize","Stop level: min="+d2s(_stopLevel));
   _periodLast = _period;
   _spreadLast = _spread;
   _tradeAllowedLast = _tradeAllowed;
}

// marketinfo_Update() - Retrieves dynamic market information.
//======================================================================================================================================
void marketinfo_Update()
{
   //-- Save last
   _spreadLast = _spread;
   _tradeAllowedLast = _tradeAllowed;
   _periodLast = _period;
   
   //-- Save new
   string s = Symbol();
   _period = Period();
   _spread = MarketInfo(s, MODE_SPREAD);
   _tradeAllowed = MarketInfo(s, MODE_TRADEALLOWED);
   
   //-- Dispatch change events
   if(marketinfo_PeriodChanged() > -1)        marketinfo_OnPeriodChange();
   if(marketinfo_SpreadChanged() > -1)        marketinfo_OnSpreadChange();
   if(marketinfo_TradeAllowedChanged() > -1)  marketinfo_OnTradeAllowedChange();
}


// marketinfo_PeriodChanged() - Last value is saved in here, unlike others.
//======================================================================================================================================
double marketinfo_PeriodChanged()
{
   if(_periodLast == _period) return(-1);
   else return(_period);
}

// marketinfo_SpreadChanged() - Checks if spread has changed since last update. Returns -1 if false or spread value if true.
//======================================================================================================================================
double marketinfo_SpreadChanged()
{
   if(_spreadLast == _spread) return(-1);
   else return(_spread);
}

// marketinfo_TradeAllowedChanged() - Checks if trading privs have changed since last update. Returns -1 if not changed, or value if changed.
//======================================================================================================================================
int marketinfo_TradeAllowedChanged()
{
   if(_tradeAllowedLast == _tradeAllowed) return(-1);
   else return(_tradeAllowed);
}


// marketinfo_OnPeriodChange() - Called when spread has changed.
//======================================================================================================================================
void marketinfo_OnPeriodChange()
{
   output_Debug("marketinfo_OnPeriodChange","Period changed: "+_periodLast+"->"+_period);
}

// marketinfo_OnSpreadChange() - Called when spread has changed.
//======================================================================================================================================
void marketinfo_OnSpreadChange()
{
   output_Warning("marketinfo_OnSpreadChange","Spread changed: "+_spreadLast+"->"+_spread);
   sound_Play("spreadchange.wav");
}

// marketinfo_TradeAllowedChanged() - Called when spread has changed.
//======================================================================================================================================
void marketinfo_OnTradeAllowedChange()
{
   output_Warning("marketinfo_OnTradeAllowedChange","TradeAllowed changed: "+_tradeAllowedLast+"->"+_tradeAllowed);
}

// UTILITY GETTERS
//======================================================================================================================================
double marketinfo_GetSpread()
{
   return(_spread);
}
double marketinfo_GetMinLotSize()
{
	return(MarketInfo(Symbol(), MODE_MINLOT));
}
double marketinfo_GetMaxLotSize()
{
	return(MarketInfo(Symbol(), MODE_MAXLOT));
}
double marketinfo_GetLotSize()
{
	return(MarketInfo(Symbol(), MODE_LOTSIZE));
}




//+------------------------------------------------------------------+
//|                                              #motion2_output.mq4 |
//|                                    Copyright © 2009, Dylan Heyes |
//|                                              www.octadecimal.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Dylan Heyes"
#property link      "www.octadecimal.com"

#define OUTPUT_PREFIX "    >>[MOTION2]:"


// output_Error() - Outputs error messages.
//======================================================================================================================================
void output_Error(string caller, string msg, bool noSound=false)
{
	if(!noSound) sound_Play("error.wav");
   Print(OUTPUT_PREFIX+"["+caller+"]-> ERROR: "+msg);
   //Alert("ERROR: "+msg +"["+caller+"]");
   Sleep(200);
}

// output_Warning() - Outputs warning messages.
//======================================================================================================================================
void output_Warning(string caller, string msg, bool noSound=false)
{
	if(!noSound) sound_Play("warning.wav");
   Print(OUTPUT_PREFIX+"["+caller+"]-> WARNING: "+msg);
   //Alert("WARNING: "+msg +"["+caller+"]");
}

// output_Info() - Outputs standard messages.
//======================================================================================================================================
void output_Info(string caller, string msg)
{
   Print(OUTPUT_PREFIX+"["+caller+"]-> "+msg);
}

// output_Debug() - Outputs standard debug messages.
//======================================================================================================================================
void output_Debug(string caller, string msg)
{
   Print(OUTPUT_PREFIX+"["+caller+"]:: "+msg);
}

// output_Trace() - Outputs low-level, non-critical messages.
//======================================================================================================================================
void output_Trace(string caller, string msg)
{
   Print(OUTPUT_PREFIX+"["+caller+"]-- "+msg);
}

// output_Line() - Outputs a divider line.
//======================================================================================================================================
void output_Line()
{
   Print("==========================================================");
}



//+------------------------------------------------------------------+
//|                                               #motion2_sound.mq4 |
//|                                    Copyright © 2009, Dylan Heyes |
//|                                              www.octadecimal.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Dylan Heyes"
#property link      "www.octadecimal.com"


// sound_Play() - Plays the specified audio file.
//======================================================================================================================================
void sound_Play(string file)
{
   PlaySound("m2_"+file);
}


//+------------------------------------------------------------------+
//|                                    #motion2_fibonaccis-enums.mq4 |
//|                                    Copyright © 2009, Dylan Heyes |
//|                                              www.octadecimal.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Dylan Heyes"
#property link      "www.octadecimal.com"

//+------------------------------------------------------------------+

//-- Types
#define FIBTYPE_CONTROL	0
#define FIBTYPE_ORDER	1

//-- Params
#define FIB_TIME1  			0
#define FIB_TIME2  			1
#define FIB_PRICE1 			2
#define FIB_PRICE2 	  		3
#define FIB_PRICE1LAST 		4
#define FIB_PRICE2LAST 		5
#define FIB_BUYPRICE			6
#define FIB_SELLPRICE		7
#define FIB_PROFIT1S			8
#define FIB_PROFIT2S			9
#define FIB_PROFIT3S			10
#define FIB_PROFIT1L			11
#define FIB_PROFIT2L			12
#define FIB_PROFIT3L			13
#define FIB_RANGE				14
#define FIB_TIMEOUT			15
#define FIB_TIMEOUTTIME		16
#define FIB_LEVEL				17
#define FIB_LEVELCHANGE 	18

//-- Price Levels
#define FIBLVL_OVER			0
#define FIBLVL_LONG			1
#define FIBLVL_MID			2
#define FIBLVL_SHORT			3
#define FIBLVL_UNDER			4

//-- Colors
#define FIBCOLOR_TIMEOUT 0x0000FF
#define FIBCOLOR_NORMAL	 0x596363
#define FIBCOLOR_STOPPED 0x434488
#define FIBCOLOR_PROFIT1 0x469370
#define FIBCOLOR_PROFIT2 0x19db83


//+------------------------------------------------------------------+
//|                                     #motion2_positions-enums.mq4 |
//|                                    Copyright © 2009, Dylan Heyes |
//|                                              www.octadecimal.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Dylan Heyes"
#property link      "www.octadecimal.com"

//-- Position params
#define POSITION_FIB			0
#define POSITION_ORDER1 	1
#define POSITION_ORDER2 	2
#define POSITION_STATUS 	3
#define POSITION_DIRECTION 4
#define POSITION_PROFITS	5

//-- Orders params
#define ORDER_TYPE 			0
#define ORDER_PRICE 			1
#define ORDER_STOP 			2
#define ORDER_PROFIT 		3
#define ORDER_POSITION 		4
#define ORDER_STATUS 		5

//-- Position/Order status
#define STATUS_OPEN			0
#define STATUS_CLOSED 		1
#define STATUS_FILLED 		2


//+------------------------------------------------------------------+
//|                                        #motion2_widget-enums.mq4 |
//|                                    Copyright © 2009, Dylan Heyes |
//|                                              www.octadecimal.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Dylan Heyes"
#property link      "www.octadecimal.com"


#define NAME_PREFIX			 	"#m2_"   	// Name prefix used for object names
#define WIDGETS_MAXSWITCHES 	8				// Maximum allowed number of switches
#define WIDGETS_MAXOPTIONS  	5				// Maximum number of options per switch
#define WIDGETS_NUMPARAMS   	7				// Number of params per switch
#define STATES_NUMPARAMS    	10				// Number of params per switch

//-- Input states
#define CONTROL_OFF        0
#define CONTROL_MANUAL     1
#define CONTROL_AUTO       2
#define DIRECTION_LONG     0
#define DIRECTION_FLAT     1
#define DIRECTION_SHORT    2
#define DRAWING_OFF        0
#define DRAWING_USER       1
#define DRAWING_AUTO       2

//-- Objects
#define OBJ_X              0
#define OBJ_Y              1
#define OBJ_W              2
#define OBJ_H              3
#define OBJ_CLR            4
#define OBJ_TYPE           5
#define OBJ_STRING         6

//-- Widgets (Switch)
#define SWITCH_X           0
#define SWITCH_Y           1
#define SWITCH_W           2
#define SWITCH_H           3
#define SWITCH_STATE       4
#define SWITCH_NUMOPTIONS  5
#define SWITCH_BTNHEIGHT   6

//-- Widgets (Label)
#define LABEL_NAME         0
#define LABEL_TEXT         1

//-- Widget States
#define STATE_LABEL        2
#define STATE_LABELNAME    3
#define STATE_ACTIVE_CLR   1
#define STATE_INACTIVE_CLR 0


//+------------------------------------------------------------------+
//|                                      #motion2_keyboard-enums.mq4 |
//|                                    Copyright © 2009, Dylan Heyes |
//|                                              www.octadecimal.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Dylan Heyes"
#property link      "www.octadecimal.com"

#define KEYEVENTF_EXTENDEDKEY          0x0001
#define KEYEVENTF_KEYUP                0x0002

#define VK_0   48
#define VK_1   49
#define VK_2   50
#define VK_3   51
#define VK_4   52
#define VK_5   53
#define VK_6   54
#define VK_7   55
#define VK_8   56
#define VK_9   57
#define VK_A   65
#define VK_B   66
#define VK_C   67
#define VK_D   68
#define VK_E   69
#define VK_F   70
#define VK_G   71
#define VK_H   72
#define VK_I   73
#define VK_J   74
#define VK_K   75
#define VK_L   76
#define VK_M   77
#define VK_N   78
#define VK_O   79
#define VK_P   80
#define VK_Q   81
#define VK_R   82
#define VK_S   83
#define VK_T   84
#define VK_U   85
#define VK_V   86
#define VK_W   87
#define VK_X   88
#define VK_Y   89
#define VK_Z   90

#define VK_LBUTTON         1     // MOUSE 1 (left)
#define VK_RBUTTON         2     // MOUSE 2 (right)
#define VK_MBUTTON         4     // MOUSE 3 (middle) 
#define VK_SBUTTON1        5     // MOUSE 4 (side)
#define VK_SBUTTON2			6		// MOUSE 5 (side)

#define VK_CANCEL          3     // Control-break processing
#define VK_BACK            8     // BACKSPACE
#define VK_TAB             9     // TAB
#define VK_CLEAR           12    // CLEAR
#define VK_RETURN          13    // ENTER
#define VK_SHIFT           16    // SHIFT
#define VK_CONTROL         17    // CTRL
#define VK_MENU            18    // ALT
#define VK_PAUSE           19    // PAUSE
#define VK_CAPITAL         20    // CAPS LOCK
#define VK_ESCAPE          27    // ESC
#define VK_SPACE           32    // SPACEBAR

#define VK_PGUP            33    // PAGE UP
#define VK_PGDOWN          34    // PAGE DOWN
#define VK_END             35    // END
#define VK_HOME            36    // HOME

#define VK_LEFT            37    // LEFT ARROW
#define VK_UP              38    // UP ARROW
#define VK_RIGHT           39    // RIGHT ARROW
#define VK_DOWN            40    // DOWN ARROW

#define VK_PRINT           42    // PRINT
#define VK_SNAPSHOT        44    // PRINT SCREEN
#define VK_INSERT          45    // INS
#define VK_DELETE          46    // DEL
#define VK_HELP            47    // HELP

#define VK_LWIN            91    // Left Windows 
#define VK_RWIN            92    // Right Windows 
#define VK_APPS            93    // Applications 

#define VK_SLEEP           95    // Computer Sleep
#define VK_NUMPAD0         96    // Numeric keypad 0
#define VK_NUMPAD1         97    // Numeric keypad 1
#define VK_NUMPAD2         98    // Numeric keypad 2
#define VK_NUMPAD3         99    // Numeric keypad 3
#define VK_NUMPAD4         100   // Numeric keypad 4
#define VK_NUMPAD5         101   // Numeric keypad 5
#define VK_NUMPAD6         102   // Numeric keypad 6
#define VK_NUMPAD7         103   // Numeric keypad 7
#define VK_NUMPAD8         104   // Numeric keypad 8
#define VK_NUMPAD9         105   // Numeric keypad 9

#define VK_MULTIPLY        106   // Multiply
#define VK_ADD             107   // Add
#define VK_SEPARATOR       108   // Separator
#define VK_SUBTRACT        109   // Subtract
#define VK_DECIMAL         110   // Decimal
#define VK_DIVIDE          111   // Divide

#define VK_F1              112   // F1
#define VK_F2              113   // F2
#define VK_F3              114   // F3
#define VK_F4              115   // F4
#define VK_F5              116   // F5
#define VK_F6              117   // F6
#define VK_F7              118   // F7
#define VK_F8              119   // F8
#define VK_F9              120   // F9
#define VK_F10             121   // F10
#define VK_F11             122   // F11
#define VK_F12             123   // F12
#define VK_F13             124   // F13

#define VK_NUMLOCK         144   // NUM LOCK
#define VK_SCROLL          145   // SCROLL LOCK

#define VK_LSHIFT          160   // Left SHIFT
#define VK_RSHIFT          161   // Right SHIFT
#define VK_LCONTROL        162   // Left CONTROL
#define VK_RCONTROL        163   // Right CONTROL
#define VK_LMENU           164   // Left MENU
#define VK_RMENU           165   // Right MENU

#define VK_TILDE				192	// Tilde

