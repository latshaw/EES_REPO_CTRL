//// ------------------------------------
//// COMMS_TOP_REGBANK.v
////
//// A simple register bank with local bus decoding created to support comms_top.v
////
//// ------------------------------------
//
//module comms_top_regbank 
////#(
////   parameter LB_AWI = 24,
////   parameter LB_DWI = 32
////) 
//	(
//   // Local bus interface
//   input               lb_clk,
//   input               lb_valid,
//   input               lb_rnw,
//   input [23:0]  lb_addr,
//   input [31:0]  lb_wdata,
//   input               lb_renable, // Ignored in this module
//   output [31:0] lb_rdata
//	
////	input [17:0]			reg_data,
//	
////	input [17:0]			qdiff,
////	input [1:0]				qstat,
////	input [1:0]				buf_done,
////	input [179:0]			cirbuf_data,
////	input [17:0]			fault_data
////	input						rfprm,
////	
////	input [17:0] 			prbi,
////	input [17:0] 			prbq,
////	input [143:0] 			fltrd,
////	input [143:0] 			frrmp,	
////	input [17:0]			cfqea,
////	input [17:0]			deta,
////	input [17:0]			deta2,	
////	input [17:0]			gmes,
////	input [17:0]			pmes,
////	input [17:0]			gerror,
////	input [17:0]			perror,
////	input [17:0]			gask,
////	input [17:0]			pask,
////	input [17:0]			iask,
////	input [17:0]			qask,
////	input [3:0]				xystat,
////	input [71:0]			disc,
////	input [3:0]				fib_stat,
////	input						adc_data_clk,
////	input [9:0]				c10gx_tmp,
////	input [15:0]			lopwh,
////	input						plsdone,
////	input [15:0]			fccid,
////	input [1:0]				lmk_lock,
////	input	[1:0]				lmk_ref,
////	input [17:0]			prmp,
////	input						epcsb,
////	input [7:0]				epcsr,	
////	
////	output [17:0]			tdoff,
////	output [17:0]			mpro,
////	output [17:0]			mi,
////	output [17:0]			mirate,
////	output [17:0]			ppro,
////	output [17:0]			pi,
////	output [17:0]			pirate,
////	output [17:0]			xlimlo,
////	output [17:0]			xlimhi,
////	output [17:0]			ylimlo,
////	output [17:0]			ylimhi,
////	output [17:0]			gset,
////	output [17:0]			pset,
////	output [17:0]			prmpr,
////	output [17:0]			glos,
////	output [17:0]			gdcl,
////	output [1:0]			maglp,
////	output [17:0]			plos,
////	output [1:0]			phslp,
////	output [17:0]			poff,
////	output [31:0]			plson,
////	output [31:0]			plsoff,
////	output					rfon,
////	output					stpena,
////	output [15:0]			fib_msk_set,
////	output					fault_clear,
////	output [5:0]			ratn,
////	output [2:0]			dac_mux_sel,
////	output [17:0]			cir_rate,
////	output [17:0]			flt_rate,	
////	output [1:0]			buf_take,
////	output					kly_ch,
////	output [17:0]			qrate,
////	output [17:0]			qslope,
////	output 					qmsk,
////	output [31:0]			epcsa,
////	output [7:0]			epcsd,
////	output [3:0]			epcsc
////	output [17:0]			glow
//);
//   `include "comms_pack.vh"
//
////   localparam LOCAL_AWI = LB_AWI;
//
//   reg [31:0] lb_rdata_reg = 0;
//	reg [31:0]	rw_reg[115:0];
//	
//	reg [31:0] epcsa_rw = 32'hffffffff;
//
//   reg [23:0] lb_addr_r=0;
//   always @(posedge lb_clk) if (lb_valid && lb_rnw) lb_addr_r <= lb_addr;
//	
//	reg [31:0] lb_din=0;
//	
//
//
//
//
////always @(posedge lb_clk) if((lb_valid & ~lb_rnw )& lb_addr == 122) rw_reg[14][0] <= lb_wdata[0];
//
//
//
//
//
//
//wire [31:0] frmv = 100;
//wire [31:0] hrtv = 1;
//
//
//
//
//wire [31:0] stat1_int;
////assign stat1_int[31:16] = 0;
////assign stat1_int[15:13] = xystat[3:1]; 
////assign stat1_int[12:10] = 0;
////assign stat1_int[9] = epcsb;
////assign stat1_int[8] = ~rfprm_int;
////assign stat1_int[7:4] = 0;
////assign stat1_int[3:2] = 0;
//
//
////assign stat1_int[1] = buf_done[1];
//
////wire [31:0] stat2_int;
////assign stat2_int[31:15] = 0;
////assign stat2_int[14] = lmk_lock[1];
////assign stat2_int[13] = lmk_ref[1];
////assign stat2_int[12] = 0;
////assign stat2_int[11] = lmk_lock[0];
////assign stat2_int[10] = lmk_ref[0];
////assign stat2_int[9] = qstat[1];
////assign stat2_int[8] = qstat[0];
////assign stat2_int[7:0] = 0;
////
////
////wire [31:0] stat3_int;
////assign stat3_int[31:14] = 0;
////assign stat3_int[13] = xystat[0];
////assign stat3_int[12:0] = 0;
////
////wire [31:0] fib_stat_int;
////assign fib_stat_int[31:6] = 0;
////assign fib_stat_int[5:4] = fib_stat[3:2];
////assign fib_stat_int[3:2] = 0;
////assign fib_stat_int[1:0] = fib_stat[1:0];
//
////wire [31:0] rf_on_reg;
////assign rf_on_reg[31:1] = rw_reg[17][31:1];
////assign rf_on_reg[0] = rw_reg[17][0] & ~rfprm;
//
//reg signed[31:0]
//	reg_bank_0	=	0,
//	reg_bank_1	=	0,
//	reg_bank_2	=	0,
//	reg_bank_3	=	0,
//	reg_bank_4	=	0,
//	reg_bank_5	=	0,
//	reg_bank_6	=	0,
//	reg_bank_7	=	0,
//	reg_bank_8	=	0,
//	reg_bank_9	=	0,
//	reg_bank_a	=	0,
//	reg_bank_b	=	0,
//	reg_bank_c	=	0;
////	reg_bank_d	=	0;
////	reg_bank_e	=	0,
////	reg_bank_f	=	0;
//	
//	
//
//
//always @(posedge lb_clk) begin
//	case (lb_addr[3:0])
//		4'h0:	reg_bank_0		<=	1;//IMESF
//		4'h1: reg_bank_0		<=	2;//QMESF
//		4'h2: reg_bank_0		<=	3;//GMESFh
//		4'h3: reg_bank_0		<=	4;//PMESF
//		4'h4: reg_bank_0		<=	5;//CRRPI
//		4'h5: reg_bank_0		<=	6;//CRRRPQ
//		4'h6: reg_bank_0		<=	7;//CRRPh
//		4'h7: reg_bank_0		<=	8;//CRRPP
//		4'h8: reg_bank_0		<=	9;//CRFPI
//		4'h9: reg_bank_0		<=	10;//CRFPQ
//		4'ha: reg_bank_0		<=	11;//CRFPh
//		4'hb: reg_bank_0		<=	12;//CRFPP
//		4'hc: reg_bank_0		<=	13;//IFPWI
//		4'hd: reg_bank_0		<=	14;//IFPWQ
//		4'he: reg_bank_0		<=	15;//IFPWh
//		4'hf: reg_bank_0		<=	16;//IFPWP
//		default: reg_bank_0	<=	32'hfaceface;
//	endcase	
////	case(lb_addr[3:0])
////		4'h0: reg_bank_1		<=	{{14{fltrd[17]}},fltrd[17:0]};//IMES
////		4'h1: reg_bank_1		<=	{{14{fltrd[35]}},fltrd[35:18]};//QMES
////		4'h2: reg_bank_1		<=	{14'b0,frrmp[17:0]};//GMESh
////		4'h3: reg_bank_1		<=	{{14{frrmp[35]}},frrmp[35:18]};//PMES
//////		4'h4: reg_bank_1		<=	rw_reg[0];//grmpr
//////		4'h5: reg_bank_1		<=	rw_reg[1];//grmps
////		4'h6: reg_bank_1		<=	rw_reg[0];
////		4'h7: reg_bank_1		<=	rw_reg[0];//gseth
////		4'h8: reg_bank_1		<=	rw_reg[1];//pset
//////		4'h9: reg_bank_1		<=	iset;
//////		4'ha: reg_bank_1		<=	qset;
//////		4'hb: reg_bank_1		<=	ilde;
//////		4'hc: reg_bank_1		<=	qlde;
////		4'hd: reg_bank_1		<=	{{14{gerror[17]}},gerror[17:0]};
////		4'he: reg_bank_1		<=	{{14{perror[17]}},perror[17:0]};
//////		4'hf: reg_bank_1		<=	rw_reg[4];//iqpro
////		default: reg_bank_1	<=	32'hfaceface;	
////	endcase
////	case(lb_addr[3:0])
//////		4'h0: reg_bank_2		<=	rw_reg[5];//iqintd
//////		4'h1: reg_bank_2		<=	rw_reg[6];//iqintr
//////		4'h2: reg_bank_2		<=	rw_reg[7];//iqderm
//////		4'h3: reg_bank_2		<=	rw_reg[8];//iqderr
//////		4'h4: reg_bank_2		<=	ipidiq;
//////		4'h5: reg_bank_2		<=	qpidiq;
//////		4'h6: reg_bank_2		<=	gpidiq;
//////		4'h7: reg_bank_2		<=	ppidiq;
//////		4'h8: reg_bank_2		<=	icrdc;
//////		4'h9: reg_bank_2		<=	qcrdc;
//////		4'ha: reg_bank_2		<=	gcrdc;
//////		4'hb: reg_bank_2		<=	pcrdc;
//////		4'hc: reg_bank_2		<=	ildemp;
//////		4'hd: reg_bank_2		<=	qldemp;
//////		4'he: reg_bank_2		<=	gldemp;
//////		4'hf: reg_bank_2		<=	pldemp;
////		default: reg_bank_2	<=	32'hfaceface;	
////	endcase
////	case(lb_addr[3:0])
////		4'h0: reg_bank_3		<=	rw_reg[2];//mpro
////		4'h1: reg_bank_3		<=	rw_reg[3];//mintd
////		4'h2: reg_bank_3		<=	rw_reg[4];//mintr
//////		4'h3: reg_bank_3		<=	rw_reg[12];//mderm
//////		4'h4: reg_bank_3		<=	rw_reg[13];//mderr
////		4'h5: reg_bank_3		<=	rw_reg[5];//ppro
////		4'h6: reg_bank_3		<=	rw_reg[6];//pintd
////		4'h7: reg_bank_3		<=	rw_reg[7];//pintr
//////		4'h8: reg_bank_3		<=	rw_reg[17];//pderm
//////		4'h9: reg_bank_3		<=	rw_reg[18];//pderr
//////		4'ha: reg_bank_3		<=	ipidmp;
//////		4'hb: reg_bank_3		<=	qpidmp;
//////		4'hc: reg_bank_3		<=	gpidmp;
//////		4'hd: reg_bank_3		<=	ppidmp;
////		4'he: reg_bank_3		<=	rw_reg[8];
////		4'hf: reg_bank_3		<=	rw_reg[9];
////		default: reg_bank_3	<=	32'hfaceface;	
////	endcase
////	case(lb_addr[3:0])
//////		4'h0: reg_bank_4		<=	rw_reg[21];//plsghi
//////		4'h1: reg_bank_4		<=	rw_reg[22];//plsglo
////		4'h2: reg_bank_4		<=	rw_reg[10];//glos
////		4'h3: reg_bank_4		<=	rw_reg[11];//plos
////		4'h4: reg_bank_4		<=	rw_reg[12];//gdcl
////		4'h5: reg_bank_4		<=	rw_reg[13];//gdal
////		4'h6: reg_bank_4		<=	rw_reg[14];//poff
//////		4'h7: reg_bank_4		<=	rw_reg[28];//pspns
//////		4'h8: reg_bank_4		<=	rw_reg[29];//pspnr
////		4'h9: reg_bank_4		<=	{{14{iask[17]}},iask[17:0]};
////		4'ha: reg_bank_4		<=	{{14{qask[17]}},qask[17:0]};
////		4'hb: reg_bank_4		<=	{14'b0,gask[17:0]};
////		4'hc: reg_bank_4		<=	{{14{pask[17]}},pask[17:0]};
////		4'hd: reg_bank_4		<=	qrate_reg;//qrate
////		4'he: reg_bank_4		<=	qslope_reg;//qslope
////		4'hf: reg_bank_4		<=	{{14{qdiff[17]}},qdiff[17:0]};
////		default: reg_bank_4	<=	32'hfaceface;	
////	endcase
////	case(lb_addr[3:0])
////		4'h0: reg_bank_5		<=	rw_reg[15];
////		4'h1: reg_bank_5		<=	{{14{cfqea[17]}},cfqea[17:0]};
////		4'h2: reg_bank_5		<=	{{14{deta[17]}},deta[17:0]};		
////		4'h3: reg_bank_5		<=	{{14{disc[53]}},disc[53:36]};
////		4'h4: reg_bank_5		<=	{{14{disc[35]}},disc[35:18]};
////		4'h5: reg_bank_5		<=	{{14{disc[17]}},disc[17:0]};
//////		4'h6: reg_bank_5		<=	rw_reg[37];//qcht		
////		4'h7: reg_bank_5		<=	{{14{disc[71]}},disc[71:54]};
//////		4'h8: reg_bank_5		<=	qchd;
//////		4'h9: reg_bank_5		<=	rw_reg[38];//tdoff
//////		4'ha: reg_bank_5		<=	cfqea;
//////		4'hb: reg_bank_5		<=	deta;
//////		4'hc: reg_bank_5		<=	rw_reg[39];//zpro
//////		4'hd: reg_bank_5		<=	rw_reg[40];//zintd
//////		4'he: reg_bank_5		<=	rw_reg[41];//zintr
//////		4'hf: reg_bank_5		<=	rw_reg[42];//zderm
////		default: reg_bank_5	<=	32'hfaceface;	
////	endcase
////	case(lb_addr[3:0])
////		4'h0: reg_bank_6		<=	{16'b0,lopwh[15:0]};
//////		4'h1: reg_bank_6		<=	rw_reg[44];//zvoff
//////		4'h2: reg_bank_6		<=	zpid;
//////		4'h3: reg_bank_6		<=	dfqel;
//////		4'h4: reg_bank_6		<=	dfqes;
//////		4'h5: reg_bank_6		<=	dfqed;
//////		4'h6: reg_bank_6		<=	rw_reg[45];//prbisp
//////		4'h7: reg_bank_6		<=	rw_reg[46];//prbqsp
//////		4'h8: reg_bank_6		<=	rw_reg[47];//auxisp
//////		4'h9: reg_bank_6		<=	rw_reg[48];//auxqsp
//////		4'ha: reg_bank_6		<=	rw_reg[49];//rflisp
//////		4'hb: reg_bank_6		<=	rw_reg[50];//rflqsp
//////		4'hc: reg_bank_6		<=	rw_reg[51];//fwdisp
//////		4'hd: reg_bank_6		<=	rw_reg[52];//fwdqsp
//////		4'he: reg_bank_6		<=	rw_reg[53];//refisp
//////		4'hf: reg_bank_6		<=	rw_reg[54];//refqisp
////		default: reg_bank_6	<=	32'hfaceface;	
////	endcase
////	case(lb_addr[3:0])
////		4'h0: reg_bank_7		<=	0;
////		4'h1: reg_bank_7		<=	0;
////		4'h2: reg_bank_7		<=	tmpd_ext;
////		4'h3: reg_bank_7		<=	frmv;//dacs1
////		4'h4: reg_bank_7		<=	hrtv;//
////		4'h5: reg_bank_7		<=	stat1_int;//
////		4'h6: reg_bank_7		<=	stat2_int;//
////		4'h7: reg_bank_7		<=	stat3_int;
////		4'h8: reg_bank_7		<=	rw_reg[16];//cntl1
////		4'h9: reg_bank_7		<=	rw_reg[17];//cntl2
////		4'ha:	reg_bank_7		<=	cntl3_reg;
//////		4'ha: reg_bank_7		<=	rw_reg[14];//cntl3
////		4'hb: reg_bank_7		<=	rw_reg[19];//cntl4
////		4'hc: reg_bank_7		<=	0;
////		4'hd: reg_bank_7		<=	0;//dacmux
////		4'he: reg_bank_7		<=	0;
////		4'hf: reg_bank_7		<=	0;
////		default: reg_bank_7	<=	32'hfaceface;	
////	endcase
////	case(lb_addr[3:0])
//////		4'h0: reg_bank_8		<=	frmv;
//////		4'h1: reg_bank_8		<=	hrtv;
//////		4'h2: reg_bank_8		<=	stat_int;//replaced with stat_int for testing, originally stat1
//////		4'h3: reg_bank_8		<=	stat2;
////		4'h4: reg_bank_8		<=	fib_stat_int;
////		4'h5: reg_bank_8		<=	rw_reg[20];
//////		4'h6: reg_bank_8		<=	rw_reg[63];//cntl3
//////		4'h7: reg_bank_8		<=	rw_reg[64];//iirk1
//////		4'h8: reg_bank_8		<=	rw_reg[65];//iirk2
//////		4'h9: reg_bank_8		<=	rw_reg[66];//iirk3
//////		4'ha: reg_bank_8		<=	rw_reg[67];//iirk4
//////		4'hb: reg_bank_8		<=	isoo;
//////		4'hc: reg_bank_8		<=	rw_reg[68];//isoom
//////		4'hd: reg_bank_8		<=	isoi;
//////		4'he: reg_bank_8		<=	rw_reg[17];
////		4'he: reg_bank_8		<=	epcsa_rw;
////		4'hf: reg_bank_8		<=	rw_reg[22];
////		default: reg_bank_8	<=	32'hfaceface;	
////	endcase
////	case(lb_addr[3:0])
////		4'h0: reg_bank_9		<=	rw_reg[23];
//////		4'h1: reg_bank_9		<=	digo;
////		4'h2: reg_bank_9		<=	epcsr;
//////		4'h3: reg_bank_9		<=	toro;
//////		4'h4: reg_bank_9		<=	rw_reg[72];//torom
//////		4'h5: reg_bank_9		<=	ledo;
//////		4'h6: reg_bank_9		<=	rw_reg[73];//ledom
//////		4'h7: reg_bank_9		<=	rw_reg[74];//ledos
//////		4'h8: reg_bank_9		<=	jmpr;
//////		4'h9: reg_bank_9		<=	rw_reg[75];//cnfga
//////		4'ha: reg_bank_9		<=	rw_reg[76];//cnfgd
//////		4'hb: reg_bank_9		<=	rw_reg[77];//cnfgc
//////		4'hc: reg_bank_9		<=	cnfgal;
//////		4'hd: reg_bank_9		<=	cnfgdl;
//////		4'he: reg_bank_9		<=	cnfgcl;
//////		4'hf: reg_bank_9		<=	rw_reg[78];//trgs1
////		default: reg_bank_9	<=	32'hfaceface;	
////	endcase
////	case(lb_addr[3:0])
//////		4'h0: reg_bank_a		<=	rw_reg[79];//trgs2
//////		4'h1: reg_bank_a		<=	rw_reg[80];//trgs3
//////		4'h2: reg_bank_a		<=	rw_reg[81];//trgs4
//////		4'h3: reg_bank_a		<=	rw_reg[82];//trgs5
//////		4'h4: reg_bank_a		<=	rw_reg[83];//trgs6
//////		4'h5: reg_bank_a		<=	rw_reg[84];//trgs7
//////		4'h6: reg_bank_a		<=	rw_reg[85];//trgs8
//////		4'h7: reg_bank_a		<=	rw_reg[86];//trgd1
//////		4'h8: reg_bank_a		<=	rw_reg[87];//trgd2
//////		4'h9: reg_bank_a		<=	rw_reg[88];//trgd3
//////		4'ha: reg_bank_a		<=	rw_reg[89];//trgd4
//////		4'hb: reg_bank_a		<=	rw_reg[90];//trgd5
//////		4'hc: reg_bank_a		<=	rw_reg[91];//trgd6
//////		4'hd: reg_bank_a		<=	rw_reg[92];//trgd7
//////		4'he: reg_bank_a		<=	rw_reg[93];//trgd8
////		4'hf: reg_bank_a		<=	rw_reg[24];//dsets
////		default: reg_bank_a	<=	32'hfaceface;	
////	endcase
////	case(lb_addr[3:0])
////		4'h0: reg_bank_b		<=	rw_reg[25];
//////		4'h1: reg_bank_b		<=	dinf2;
//////		4'h2: reg_bank_b		<=	dinf3;
//////		4'h3: reg_bank_b		<=	dinf4;
////		4'h4: reg_bank_b		<=	prmpr_reg;
//////		4'h5: reg_bank_b		<=	dtrgd2;
//////		4'h6: reg_bank_b		<=	dtrgd3;
//////		4'h7: reg_bank_b		<=	dtrgd4;
////		4'h8: reg_bank_b		<=	rw_reg[26];
////		4'h9: reg_bank_b		<=	rw_reg[27];
////		4'ha: reg_bank_b		<=	rw_reg[28];
////		4'hb: reg_bank_b		<=	rw_reg[29];
////		4'hc: reg_bank_b		<=	{{14{prmp[17]}},prmp[17:0]};
//////		4'hd: reg_bank_b		<=	{{14{deta2[17]}},deta2[17:0]};//spr04
//////		4'he: reg_bank_b		<=	rw_reg[102];//spr05
//////		4'hf: reg_bank_b		<=	rw_reg[103];//spr06
////		default: reg_bank_b	<=	32'hfaceface;	
////	endcase
////	case(lb_addr[3:0])
////		4'h0: reg_bank_c		<=	rw_reg[30];
//////		4'h1: reg_bank_c		<=	rw_reg[105];//spr08
//////		4'h2: reg_bank_c		<=	glow_reg;//spr09
//////		4'h3: reg_bank_c		<=	rw_reg[107];//spr10
//////		4'h4: reg_bank_c		<=	rw_reg[108];//spr11
//////		4'h5: reg_bank_c		<=	rw_reg[109];//spr12
//////		4'h6: reg_bank_c		<=	rw_reg[110];//spr13
//////		4'h7: reg_bank_c		<=	rw_reg[111];//spr14
////		4'h8: reg_bank_c		<=	rw_reg[31];//spr15
////		4'h9: reg_bank_c		<=	rw_reg[32];//spr16
//////		4'ha: reg_bank_c		<=	rw_reg[114];//gmflh
////		4'hb: reg_bank_c		<=	{16'b0,fccid};//glowh		
////		default: reg_bank_c	<=	32'hfaceface;	
////	endcase	
//	casex(lb_addr_r)
////		24'b0000_0000_0000_0000_0xxx_xxxx:	lb_din			<=	{{14{reg_data[17]}},reg_data[17:0]};
//		24'h00001x:	lb_din			<=	reg_bank_1;
////		24'h00002x:	lb_din			<=	reg_bank_2;
////		24'h00003x:	lb_din			<=	reg_bank_3;
////		24'h00004x:	lb_din			<=	reg_bank_4;
////		24'h00005x:	lb_din			<=	reg_bank_5;
////		24'h00006x:	lb_din			<=	reg_bank_6;
////		24'h00007x:	lb_din			<=	reg_bank_7;
////		24'h00008x:	lb_din			<=	reg_bank_8;
////		24'h00009x:	lb_din			<=	reg_bank_9;
////		24'h0000ax:	lb_din			<=	reg_bank_a;
////		24'h0000bx:	lb_din			<=	reg_bank_b;
////		24'h0000cx:	lb_din			<=	reg_bank_c;
////		24'b0000_0000_0001_xxxx_xxxx_xxxx:	lb_din	<=	cirbuf0_data_ext;
////		24'b0000_0000_0010_xxxx_xxxx_xxxx:	lb_din	<=	cirbuf1_data_ext;
////		24'b0000_0000_0011_xxxx_xxxx_xxxx:	lb_din	<=	cirbuf2_data_ext;
////		24'b0000_0000_0100_xxxx_xxxx_xxxx:	lb_din	<=	cirbuf3_data_ext;
////		24'b0000_0000_0101_xxxx_xxxx_xxxx:	lb_din	<=	cirbuf4_data_ext;
////		24'b0000_0000_0110_xxxx_xxxx_xxxx:	lb_din	<=	cirbuf5_data_ext;
////		24'b0000_0000_0111_xxxx_xxxx_xxxx:	lb_din	<=	cirbuf6_data_ext;
////		24'b0000_0000_1000_xxxx_xxxx_xxxx:	lb_din	<=	cirbuf7_data_ext;
////		24'b0000_0000_1001_xxxx_xxxx_xxxx:	lb_din	<=	cirbuf8_data_ext;
////		24'b0000_0000_1010_xxxx_xxxx_xxxx:	lb_din	<=	cirbuf9_data_ext;
////		
////		24'b0000_0000_1011_xxxx_xxxx_xxxx:	lb_din	<=	fault_data_ext;
////		24'b0000_0000_1100_xxxx_xxxx_xxxx:	lb_din	<=	fault_data_ext;
////		24'b0000_0000_1101_xxxx_xxxx_xxxx:	lb_din	<=	fault_data_ext;
////		24'b0000_0000_1110_xxxx_xxxx_xxxx:	lb_din	<=	fault_data_ext;
////		24'b0000_0000_1111_xxxx_xxxx_xxxx:	lb_din	<=	fault_data_ext;
////		24'b0000_0001_0000_xxxx_xxxx_xxxx:	lb_din	<=	fault_data_ext;
////		24'b0000_0001_0001_xxxx_xxxx_xxxx:	lb_din	<=	fault_data_ext;
////		24'b0000_0001_0010_xxxx_xxxx_xxxx:	lb_din	<=	fault_data_ext;
////		24'b0000_0001_0010_xxxx_xxxx_xxxx:	lb_din	<=	fault_data_ext;
////		24'b0000_0001_0010_xxxx_xxxx_xxxx:	lb_din	<=	fault_data_ext;
//		
////		24'h0000dx:	lb_din	<=	reg_bank_d;
////		24'h0000ex:	lb_din	<=	reg_bank_e;
////		24'h0000fx:	lb_din	<=	reg_bank_f;
//		default:		lb_din	<=	32'hfaceface;		
//	endcase
//end	
//	
//
//
//   //assign lb_rdata = lb_rdata_reg;
//	assign lb_rdata = lb_din;
//	
//	
////	assign gset = rw_reg[0][17:0];
////	assign pset = rw_reg[1][17:0];
////	assign mpro = rw_reg[2][17:0];
////	assign mi = rw_reg[3][17:0];
////	assign mirate = rw_reg[4][17:0];
////	assign ppro = rw_reg[5][17:0];
////	assign pi = rw_reg[6][17:0];
////	assign pirate = rw_reg[7][17:0];
////	assign plson = rw_reg[8][31:0];
////	assign plsoff = rw_reg[9][31:0];
////	assign glos = rw_reg[10][17:0];
////	assign plos = rw_reg[11][17:0];
////	assign gdcl = rw_reg[12][17:0];
////	
////	assign poff = rw_reg[14][17:0];
////	assign tdoff = rw_reg[15][17:0];
////	assign buf_take = rw_reg[16][1:0];
////	assign kly_ch = rw_reg[16][2];
////	assign phslp = rw_reg[17][4:3];
////	assign maglp = rw_reg[17][2:1];
////	wire maglp_r = rw_reg[17][2]&rw_reg[17][1];
////	
////	assign qmsk = rw_reg[18][8];
////	
////	reg flt_clr = 0;
////	always@ (posedge lb_clk) flt_clr <= oup_flt_clr;
////	reg flt_clr_buf = 0;
////	always@ (posedge lb_clk) flt_clr_buf <= flt_clr;
////	reg fault_clear_reg = 0;
////	always@ (posedge lb_clk) fault_clear_reg = oup_flt_clr || flt_clr;
////	assign fault_clear = flt_clr;
//	
////	assign qrate = qrate_reg[17:0];
////	assign qslope = qslope_reg[17:0];
////	assign prmpr = prmpr_reg[17:0];
//	
////	assign fib_msk_set = rw_reg[20][15:0];
////	assign epcsa = rw_reg[17];
////	assign epcsa = epcsa_rw;
////	assign epcsd = rw_reg[22][7:0];
////	assign epcsc = rw_reg[23][3:0];
////	assign rfon = rw_reg[24][0];
////	assign rfon = rf_on_reg[0];
////	assign ratn = rw_reg[25][5:0];
////	assign xlimlo = rw_reg[26][17:0];
////	assign xlimhi = rw_reg[27][17:0];
////	assign ylimlo = rw_reg[28][17:0];
////	assign ylimhi = rw_reg[29][17:0];
////	assign stpena = rw_reg[30][0] & rw_reg[24][0];
////	assign cir_rate = rw_reg[31][17:0];
////	assign flt_rate = rw_reg[32][17:0];
//	
//	
////	assign stat1_int[0] = maglp_r? plsdone&buf_done[0] : buf_done[0];
//	//assign glow	=	glow_reg[17:0];
//	
//	
//	
////	assign dac_mux_sel = rw_reg[62][4:2];
//	
//	
//	
//
//endmodule
