package com.kzw.core.mapper;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.List;

import org.apache.commons.beanutils.ConvertUtils;
import org.apache.commons.beanutils.converters.DateConverter;
import org.apache.commons.lang3.StringUtils;
import org.dozer.DozerBeanMapper;

import com.kzw.core.util.ReflectionUtils;

/**
 * 对象转换工具类.
 * 1.封装Dozer, 深度转换对象到对象  <dozer功能与beanUtils相同>
 * 2.封装Apache Commons BeanUtils, 将字符串转换为对象.
 */
@SuppressWarnings("unchecked")
public abstract class BeanMapper {

	/**
	 * 持有Dozer单例, 避免重复创建DozerMapper消耗资源.
	 */
	private static DozerBeanMapper dozer = new DozerBeanMapper();
	private BeanMapper() {
	}

	/**
	 * 基于Dozer转换对象的类型.
	 */
	public static <T> T map(Object source, Class<T> destinationClass) {
		return dozer.map(source, destinationClass);
	}

	/**
	 * 基于Dozer转换Collection中对象的类型.
	 */
	public static <T> List<T> mapList(Collection sourceList, Class<T> destinationClass) {
		List<T> destinationList = new ArrayList<T>();
		for (Object sourceObject : sourceList) {
			T destinationObject = dozer.map(sourceObject, destinationClass);
			destinationList.add(destinationObject);
		}
		return destinationList;
	}

	static {
		//初始化日期格式为yyyy-MM-dd 或 yyyy-MM-dd HH:mm:ss
		registerDateConverter("yyyy-MM-dd,yyyy-MM-dd HH:mm:ss");
	}

	/**
	 * 定义Apache BeanUtils日期Converter的格式,可注册多个格式,以','分隔
	 */
	public static void registerDateConverter(String patterns) {
		DateConverter dc = new DateConverter();
		dc.setUseLocaleFormat(true);
		dc.setPatterns(StringUtils.split(patterns, ","));
		ConvertUtils.register(dc, Date.class);
	}

	/**
	 * 基于Apache BeanUtils转换字符串到相应类型.
	 * 
	 * @param value 待转换的字符串.
	 * @param toType 转换目标类型.
	 */
	public static <T> T convertToObject(String value, Class<T> toType) {
		try {
			return (T)ConvertUtils.convert(value, toType);
		} catch (Exception e) {
			throw ReflectionUtils.convertReflectionExceptionToUnchecked(e);
		}
	}
	
	/**
	 * 基于Dozer将对象A的值拷贝到对象B中.
	 */
	public static void copy(Object source, Object destinationObject) {
		dozer.map(source, destinationObject);
	}
}