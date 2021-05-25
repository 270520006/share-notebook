# Jquery操作DOM对象

## select操作

```java
var checkText=$("#select_id").find("option:selected").text(); //获取Select选择的text
var checkValue=$("#select_id").val(); //获取Select选择的Value
var checkIndex=$("#select_id ").get(0).selectedIndex; //获取Select选择的索引值
var maxIndex=$("#select_id option:last").attr("index"); //获取Select最大的索引值
```