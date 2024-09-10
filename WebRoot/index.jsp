<%@ page language="java" pageEncoding="UTF-8"%>
<%@page import="com.kzw.core.util.spring.SpringContextHolder"%>
<%@page import="com.kzw.system.service.MenuService"%>
<%@page import="java.util.List"%>
<%@page import="com.kzw.system.entity.Menu"%>
<%@page import="com.kzw.system.entity.AppUser"%>
<%
String path = request.getContextPath();
AppUser currUser = (AppUser)session.getAttribute("USER");
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
MenuService menuService = SpringContextHolder.getBean("menuService");
List<Menu> menus = menuService.listMyMenu(currUser);
%>
<!DOCTYPE html>
<html lang="en-us">	
	<head>
		<meta charset="utf-8">
		<base href="<%=basePath%>">
		<title>健身房后台管理系统</title>
		<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
		
		<!-- #CSS Links -->
		<!-- SmartAdmin Styles : Caution! DO NOT change the order -->
		<link rel="stylesheet" type="text/css" media="screen" href="css/smartadmin-production-plugins.min.css">
		<link rel="stylesheet" type="text/css" media="screen" href="css/smartadmin-production.min.css">
		<link rel="stylesheet" type="text/css" media="screen" href="css/smartadmin-skins.min.css">

		<!-- SmartAdmin RTL Support -->
		<link rel="stylesheet" type="text/css" media="screen" href="css/smartadmin-rtl.min.css"> 

		<!-- Basic Styles -->
		<link rel="stylesheet" type="text/css" media="screen" href="css/font-awesome.min.css">
		<link rel="stylesheet" type="text/css" media="screen" href="css/bootstrap.min.css">

		<link rel="stylesheet" type="text/css" media="screen" href="css/jqgrid/ui.jqgrid-bootstrap.css">
		<link rel="stylesheet" type="text/css" media="screen" href="css/your_style.css">

		<!-- Demo purpose only: goes with demo.js, you can delete this css when designing your own WebApp -->
		<link rel="stylesheet" type="text/css" media="screen" href="css/demo.min.css">
		
		<!-- icheck -->
		<link rel="stylesheet" type="text/css" media="screen" href="js/plugin/icheck/skins/all.css">

		<!-- #FAVICONS -->

	</head>

	<!--

	TABLE OF CONTENTS.
	
	Use search to find needed section.
	
	===================================================================
	
	|  01. #CSS Links                |  all CSS links and file paths  |
	|  02. #FAVICONS                 |  Favicon links and file paths  |
	|  03. #GOOGLE FONT              |  Google font link              |
	|  04. #APP SCREEN / ICONS       |  app icons, screen backdrops   |
	|  05. #BODY                     |  body tag                      |
	|  06. #HEADER                   |  header tag                    |
	|  07. #PROJECTS                 |  project lists                 |
	|  08. #TOGGLE LAYOUT BUTTONS    |  layout buttons and actions    |
	|  09. #MOBILE                   |  mobile view dropdown          |
	|  10. #SEARCH                   |  search field                  |
	|  11. #NAVIGATION               |  left panel & navigation       |
	|  12. #MAIN PANEL               |  main panel                    |
	|  13. #MAIN CONTENT             |  content holder                |
	|  14. #PAGE FOOTER              |  page footer                   |
	|  15. #SHORTCUT AREA            |  dropdown shortcuts area       |
	|  16. #PLUGINS                  |  all scripts and plugins       |
	
	===================================================================
	
	-->
	
	<!-- #BODY -->
	<!-- Possible Classes

		* 'smart-style-{SKIN#}'
		* 'smart-rtl'         - Switch theme mode to RTL
		* 'menu-on-top'       - Switch to top navigation (no DOM change required)
		* 'no-menu'			  - Hides the menu completely
		* 'hidden-menu'       - Hides the main menu but still accessable by hovering over left edge
		* 'fixed-header'      - Fixes the header
		* 'fixed-navigation'  - Fixes the main menu
		* 'fixed-ribbon'      - Fixes breadcrumb
		* 'fixed-page-footer' - Fixes footer
		* 'container'         - boxed layout mode (non-responsive: will not work with fixed-navigation & fixed-ribbon)
	-->
	<body class="smart-style-5">

		<!-- #HEADER -->
		<header id="header">
			<div id="logo-group">

				<!-- PLACE YOUR LOGO HERE -->
				<span id="logo" style="font-weight: bold; font-size: 18px;"> 
					<!-- <img src="img/logo.png" alt="SmartAdmin"> -->
					健身房管理系统
				 </span>
				<!-- END LOGO PLACEHOLDER -->
				
			</div>
		
			
			<!-- #TOGGLE LAYOUT BUTTONS -->
			<!-- pulled right: nav area -->
			<div class="pull-right">
				
				<!-- logout button -->
				<div id="logout" class="btn-header transparent pull-right">
					<span> <a href="user/logout" title="退出系统" data-action="userLogout">退出系统</i></a> </span>
				</div>
				<!-- end logout button -->
				
				<!-- collapse menu button -->
				<!-- <div id="hide-menu" class="btn-header pull-right">
					<span> <a href="javascript:void(0);" data-action="toggleMenu" title="Collapse Menu"><i class="fa fa-reorder"></i></a> </span>
				</div> -->
				<!-- end collapse menu -->

				<!-- fullscreen button -->
				<!-- <div id="fullscreen" class="btn-header transparent pull-right">
					<span> <a href="javascript:void(0);" data-action="launchFullscreen" title="Full Screen"><i class="fa fa-arrows-alt"></i></a> </span>
				</div> -->
				<!-- end fullscreen button -->
				

			</div>
			<!-- end pulled right: nav area -->

		</header>
		<!-- END HEADER -->

		<!-- #NAVIGATION -->
		<!-- Left panel : Navigation area -->
		<!-- Note: This width of the aside area can be adjusted through LESS/SASS variables -->
		<aside id="left-panel">

			<!-- User info -->
			<div class="login-info">
				<span> <!-- User image size is adjusted inside CSS, it should stay as is --> 
					
					<a  id="show-shortcut" data-action="toggleShortcut">
						<!-- <img src="img/avatars/sunny.png" alt="me" class="online" />  -->
						<span>
							欢迎您：${USER.realName}
						</span>
					</a> 
					
				</span>
			</div>
			<!-- end user info -->

			<!-- NAVIGATION : This navigation is also responsive

			To make this navigation dynamic please make sure to link the node
			(the reference to the nav > ul) after page load. Or the navigation
			will not initialize.
			-->
			<nav>
				<ul>
					<%
					int level = -1;
					for(int k=0; k<menus.size(); k++) {
						Menu menu = menus.get(k);
						int currLevel = menu.getLevel();
						if(currLevel >= level) { //子结点
							level = currLevel;
						%>
						<li>
							<a href="<%=menu.getUrl()%>" title="<%=menu.getName()%>">
								<i class="<%=menu.getIconCls()%>"></i> 
								<span class="menu-item-parent"><%=menu.getName()%></span>
							</a>
							<%
							if(!menu.getLeaf()) {
								out.print("<ul>");		
							} else {
								out.print("</li>");
							}
							%>
						<%
						} else if(currLevel < level) { //子结点结束
							for(int i=0; i<level-currLevel; i++) {
								out.print("</ul></li>");		
							}
							level = currLevel -1;
							k = k - 1;  // 循环回退一次
						}
					}
					// 最后一个的深度
					if(menus.size() > 0) {
						level = menus.get(menus.size()-1).getLevel();
						for(int i=0; i<level; i++) {
							out.print("</ul></li>");
						}
					} else {
					%>
						<li>
							<a href="menu/view" title="菜单管理">
								<i class="glyphicon glyphicon-align-center"></i> 
								<span class="menu-item-parent">菜单管理</span>
							</a>
						</li>
					<%
					}					
					%>			
				</ul>
			</nav>

			<span class="minifyme" data-action="minifyMenu"> <i class="fa fa-arrow-circle-left hit"></i> </span>

		</aside>
		<!-- END NAVIGATION -->
		
		<!-- #MAIN PANEL -->
		<div id="main" role="main">

			<!-- RIBBON -->
			<div id="ribbon">
				 <!-- 刷新 -->
				<span class="ribbon-button-alignment">
				    <a href="#" id="search" class="btn btn-ribbon hidden-xs" data-title="search"><i class="fa fa-grid"></i> 刷新</a>
				</span>
                <!-- end刷新 -->
				<!-- breadcrumb -->
				<ol class="breadcrumb">
					<!-- This is auto generated -->
				</ol>
				<!-- end breadcrumb -->

				<!-- You can also add more buttons to the
				ribbon for further usability

				Example below:

				<span class="ribbon-button-alignment pull-right" style="margin-right:25px">
					<a href="#" id="search" class="btn btn-ribbon hidden-xs" data-title="search"><i class="fa fa-grid"></i> Change Grid</a>
					<span id="add" class="btn btn-ribbon hidden-xs" data-title="add"><i class="fa fa-plus"></i> Add</span>
					<button id="search" class="btn btn-ribbon" data-title="search"><i class="fa fa-search"></i> <span class="hidden-mobile">Search</span></button>
				</span> -->

			</div>
			<!-- END RIBBON -->

			<!-- #MAIN CONTENT -->
			<div id="content">

			</div>
			
			<!-- END #MAIN CONTENT -->

		</div>
		<!-- END #MAIN PANEL -->

		<!-- #PAGE FOOTER -->
		<!--  
		<div class="page-footer">
			<div class="row">
				<div class="col-xs-12 col-sm-6">
					<span class="txt-color-white">版权所有 © 2016</span>
				</div>
			</div>
		</div>
		-->
		<!-- END FOOTER -->

		<!--================================================== -->

		<!-- PACE LOADER - turn this on if you want ajax loading to show (caution: uses lots of memory on iDevices)
		<script data-pace-options='{ "restartOnRequestAfter": true }' src="js/plugin/pace/pace.min.js"></script>-->


		<!-- #PLUGINS -->
		<!-- Link to Google CDN's jQuery + jQueryUI; fall back to local -->
		<script src="js/libs/jquery-2.1.1.min.js"></script>
		<script src="js/libs/jquery-ui-1.10.3.min.js"></script>

		<!-- IMPORTANT: APP CONFIG -->
		<script src="js/app.config.js"></script>

		<!-- JS TOUCH : include this plugin for mobile drag / drop touch events-->
		<script src="js/plugin/jquery-touch/jquery.ui.touch-punch.min.js"></script> 

		<!-- BOOTSTRAP JS -->
		<script src="js/bootstrap/bootstrap.min.js"></script>

		<!-- CUSTOM NOTIFICATION -->
		<script src="js/notification/SmartNotification.min.js"></script>

		<!-- JARVIS WIDGETS -->
		<script src="js/smartwidgets/jarvis.widget.min.js"></script>

		<!-- EASY PIE CHARTS -->
		<script src="js/plugin/easy-pie-chart/jquery.easy-pie-chart.min.js"></script>

		<!-- SPARKLINES -->
		<script src="js/plugin/sparkline/jquery.sparkline.min.js"></script>

		<!-- JQUERY VALIDATE -->
		<script src="js/plugin/jquery-validate/jquery.validate.min.js"></script>

		<!-- JQUERY MASKED INPUT -->
		<script src="js/plugin/masked-input/jquery.maskedinput.min.js"></script>

		<!-- JQUERY SELECT2 INPUT -->
		<script src="js/plugin/select2/select2.min.js"></script>

		<!-- JQUERY UI + Bootstrap Slider -->
		<script src="js/plugin/bootstrap-slider/bootstrap-slider.min.js"></script>

		<!-- browser msie issue fix -->
		<script src="js/plugin/msie-fix/jquery.mb.browser.min.js"></script>

		<!-- FastClick: For mobile devices: you can disable this in app.js -->
		<script src="js/plugin/fastclick/fastclick.min.js"></script>

		<!--[if IE 8]>
			<h1>Your browser is out of date, please update your browser by going to www.microsoft.com/download</h1>
		<![endif]-->

		
		<!-- MAIN APP JS FILE -->
		<script src="js/demo.min.js"></script>
		<script src="js/app.min.js"></script>

		<!-- SmartChat UI : plugin -->
		<script src="js/smart-chat-ui/smart.chat.ui.min.js"></script>
		<script src="js/smart-chat-ui/smart.chat.manager.min.js"></script>
		
		<!-- jqGrid -->
		<!--  
		<script src="js/plugin/jqgrid/jquery.jqGrid.min.js"></script>
		-->
		<script src="js/plugin/jqgrid/src/jquery.jqGrid.js"></script>
		<script src="js/plugin/jqgrid/grid.locale-cn.js"></script>
		
		<!-- layer -->
		<script src="js/plugin/layer/layer.js"></script>
		<!-- 时间选择器 -->
		<script src="js/plugin/My97DatePicker/WdatePicker.js"></script>
		<!-- 下拉选择框 -->
		<script src="js/plugin/bootstrap-select/bootstrap-select.min.js"></script>
		
		<script src="js/KeExt.js"></script>

		<script type="text/javascript" src="js/plugin/jquery-layout/jquery.layout-latest.js"></script>
		
		<script type="text/javascript" src="js/plugin/icheck/icheck.js"></script>
		
		<script>
		$(function() {			
			$('#main').height($(document).height() - 110);
			$(window).resize(function() {
				$('#main').height($(document).height() - 110);
			});
		});
		</script>
		
	</body>

</html>