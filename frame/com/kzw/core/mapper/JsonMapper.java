package com.kzw.core.mapper;

import java.io.IOException;
import java.io.OutputStream;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.annotation.AnnotationUtils;

import com.fasterxml.jackson.annotation.JsonFilter;
import com.fasterxml.jackson.annotation.JsonInclude.Include;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.JavaType;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.databind.ser.impl.SimpleBeanPropertyFilter;
import com.fasterxml.jackson.databind.ser.impl.SimpleFilterProvider;


/**
 * 简单封装Jackson实现JSON<->Java Object的Mapper.
 * 封装不同的输出风格, 使用不同的builder函数创建实例.
 * 	ObjectMapper.setDateFormat();
 * 解决ORM中实体对象一对多双向引用
 * 	@JsonManagedReference: 渲染引用属性
 * 	@JsonBackReference: 不渲染引用属性
 * 动态渲染指定属性, 需要使用@JsonFilter("xxx")
 * 	FilterProvider myfilter = new SimpleFilterProvider()
 		.addFilter("xxx", SimpleBeanPropertyFilter.serializeAllExcept(properName,...));
 * 	ObjectMapper.setFilters(myfilter);
 */
@SuppressWarnings("unchecked")
public class JsonMapper {

	private static Logger logger = LoggerFactory.getLogger(JsonMapper.class);

	private ObjectMapper mapper;

	public JsonMapper() {
		this(null);
	}

	public void setDateFormat(DateFormat df) {
		mapper.setDateFormat(df);
	}
	public void setDateFormat(String pattern) {
		DateFormat df = new SimpleDateFormat(pattern);
		mapper.setDateFormat(df);
	}
	
	public JsonMapper(Include include) {
		mapper = new ObjectMapper();
		// 设置输出时包含属性的风格
		if (include != null) {
			mapper.setSerializationInclusion(include);
		}
		// 设置输入时忽略在JSON字符串中存在但Java对象实际没有的属性
		mapper.disable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES);
	}

	/**
	 * 创建只输出非Null且非Empty(如List.isEmpty)的属性到Json字符串的Mapper,建议在外部接口中使用.
	 */
	public static JsonMapper nonEmptyMapper() {
		return new JsonMapper(Include.NON_EMPTY);
	}

	/**
	 * 创建只输出初始值被改变的属性到Json字符串的Mapper, 最节约的存储方式，建议在内部接口中使用。
	 */
	public static JsonMapper nonDefaultMapper() {
		return new JsonMapper(Include.NON_DEFAULT);
	}

	/**
	 * Object可以是POJO，也可以是Collection或数组。
	 * 如果对象为Null, 返回"null".
	 * 如果集合为空集合, 返回"[]".
	 */
	public String toJson(Object object) {
		try {
			return mapper.writeValueAsString(object);
		} catch (IOException e) {
			logger.warn("write to json string error:" + object, e);
			return null;
		}
	}

	/**
	 * 反序列化POJO或简单Collection如List<String>.
	 * 
	 * 如果JSON字符串为Null或"null"字符串, 返回Null.
	 * 如果JSON字符串为"[]", 返回空集合.
	 * 
	 * 如需反序列化复杂Collection如List<MyBean>, 请使用fromJson(String, JavaType)
	 * 
	 * @see #fromJson(String, JavaType)
	 */
	public <T> T fromJson(String jsonString, Class<T> clazz) {
		if (StringUtils.isEmpty(jsonString)) {
			return null;
		}

		try {
			return mapper.readValue(jsonString, clazz);
		} catch (IOException e) {
			logger.warn("parse json string error:" + jsonString, e);
			return null;
		}
	}

	/**
	 * 反序列化复杂Collection如List<Bean>, 先使用createCollectionType()或contructMapType()构造类型, 然后调用本函数.
	 * 
	 * @see #createCollectionType(Class, Class...)
	 */
	public <T> T fromJson(String jsonString, JavaType javaType) {
		if (StringUtils.isEmpty(jsonString)) {
			return null;
		}

		try {
			return (T) mapper.readValue(jsonString, javaType);
		} catch (IOException e) {
			logger.warn("parse json string error:" + jsonString, e);
			return null;
		}
	}

	/**
	 * 构造Collection类型. 作为fromJson方法参数
	 */
	public JavaType contructCollectionType(Class<? extends Collection> collectionClass, Class<?> elementClass) {
		return mapper.getTypeFactory().constructCollectionType(collectionClass, elementClass);
	}
	/**
	 * 构造Map类型. 作为fromJson方法参数
	 */
	public JavaType contructMapType(Class<? extends Map> mapClass, Class<?> keyClass, Class<?> valueClass) {
		return mapper.getTypeFactory().constructMapType(mapClass, keyClass, valueClass);
	}

	/**
	 * 当JSON里只含有Bean的部分屬性時，更新一個已存在Bean，只覆蓋該部分的屬性.
	 */
	public void update(String jsonString, Object object) {
		try {
			mapper.readerForUpdating(object).readValue(jsonString);
		} catch (JsonProcessingException e) {
			logger.warn("update json string:" + jsonString + " to object:" + object + " error.", e);
		} catch (IOException e) {
			logger.warn("update json string:" + jsonString + " to object:" + object + " error.", e);
		}
	}


	/**
	 * 設定是否使用Enum的toString函數來讀寫Enum,
	 * 為False時時使用Enum的name()函數來讀寫Enum, 默認為False.
	 * 注意本函數一定要在Mapper創建後, 所有的讀寫動作之前調用.
	 */
	public void enableEnumUseToString() {
		mapper.enable(SerializationFeature.WRITE_ENUMS_USING_TO_STRING);
		mapper.enable(DeserializationFeature.READ_ENUMS_USING_TO_STRING);
	}

	/**
	 * 取出Mapper做进一步的设置或使用其他序列化API.
	 */
	public ObjectMapper getMapper() {
		return mapper;
	}

	// ***********************对Jackson JSON的二次包装***********************

	/**
	 * 对指定的属性进行JSON渲染
	 * value对象上必须设置@JsonFilter注解
	 */
	public String toJsonWith(Object value, String... properties) {
		try {
			return mapper.writer(
					new SimpleFilterProvider().addFilter(AnnotationUtils.getValue(
							AnnotationUtils.findAnnotation(value.getClass(), JsonFilter.class))
							.toString(), SimpleBeanPropertyFilter.filterOutAllExcept(properties))
					).writeValueAsString(value);
		} catch (IOException e) {
			logger.warn("write to json string error:" + value, e);
			return null;
		}
	}

	/**
	 * 过滤指定的属性进行JSON渲染
	 * */
	public String toJsonWithout(Object value, String... properties) {
		try {
			return mapper.writer(
					new SimpleFilterProvider().addFilter(
							AnnotationUtils.getValue(AnnotationUtils.findAnnotation(value.getClass(), JsonFilter.class))
							.toString(), SimpleBeanPropertyFilter.serializeAllExcept(properties))
					).writeValueAsString(value);
		} catch (IOException e) {
			logger.warn("write to json string error:" + value, e);
			return null;
		}
	}

	/**
	 * 将JSON写到输出流中
	 * */
	public void writeJson(OutputStream out, Object value) {
		try {
			mapper.writeValue(out, value);
		} catch (IOException e) {
			logger.warn("write to json string error:" + value, e);
		}
	}

	/**
	 * 指定属性的渲染JSON，写入输出流中
	 * */
	public void writeJsonWith(OutputStream out, Object value, String... properties) {
		try {
			mapper.writer(
					new SimpleFilterProvider().addFilter(
							AnnotationUtils.getValue(AnnotationUtils.findAnnotation(value.getClass(), JsonFilter.class))
							.toString(), SimpleBeanPropertyFilter.filterOutAllExcept(properties)))
					.writeValue(out, value);
		} catch (IOException e) {
			logger.warn("write to json string error:" + value, e);
		}

	}

	/**
	 * 指定属性不渲染的JSON，写入输出流中
	 * */
	public void writeJsonWithout(OutputStream out, Object value, String... properties) {
		try {
			mapper.writer(
					new SimpleFilterProvider().addFilter(
							AnnotationUtils.getValue(AnnotationUtils.findAnnotation(value.getClass(), JsonFilter.class))
							.toString(), SimpleBeanPropertyFilter.serializeAllExcept(properties)))
					.writeValue(out, value);
		} catch (IOException e) {
			logger.warn("write to json string error:" + value, e);
		}

	}

}
