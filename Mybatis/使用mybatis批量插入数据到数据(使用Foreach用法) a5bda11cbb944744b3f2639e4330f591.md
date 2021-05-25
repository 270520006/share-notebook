# 使用mybatis批量插入数据到数据(使用Foreach用法)

## Java接口代码

```java
/**
     * 从excel文件中导入数据到数据库中
     *
     * @param userExperienceMaintainList
     * @return
     */
    Integer insertUserExperienceFromExcelFile(@Param("**paramUserExperienceMaintainList**") List<CuUserExperienceMaintain> userExperienceMaintainList);
```

## 示例代码一(如果传入的是list集合)

```xml
<insert id="insertUserExperienceFromExcelFile" parameterType="list">
        insert into cu_user_experience_maintain (id, period, user_code, user_name, begin_time, end_time, pop_ups_number,
        is_fill_questionary, is_active, create_user_name, create_user_code,
        modify_user_name, modify_user_code, create_time, update_time,
        pop_ups_content, pop_ups_link) VALUES
        <foreach collection="**paramUserExperienceMaintainList**" index="i" item="dataInfo" separator=",">
            (null,
            <if test="paramUserExperienceMaintainList.get(i).period!=null and paramUserExperienceMaintainList.get(i).period!=''">
                #{dataInfo.period},
            </if>
            <if test="paramUserExperienceMaintainList.get(i).userCode!=null and paramUserExperienceMaintainList.get(i).userCode!=''">
                #{dataInfo.userCode},
            </if>
            <if test="paramUserExperienceMaintainList.get(i).userName!=null and paramUserExperienceMaintainList.get(i).userName!=''">
                #{dataInfo.userName},
            </if>
            <if test="paramUserExperienceMaintainList.get(i).beginTime!=null and paramUserExperienceMaintainList.get(i).beginTime!=''">
                #{dataInfo.beginTime},
            </if>
            <if test="paramUserExperienceMaintainList.get(i).endTime!=null and paramUserExperienceMaintainList.get(i).endTime!=''">
                #{dataInfo.endTime},
            </if>
            #{dataInfo.popUpsNumber},
            #{dataInfo.isFillQuestionary},
            #{dataInfo.isActive},
            #{dataInfo.createUserName},
            #{dataInfo.createUserCode},
            #{dataInfo.modifyUserName},
            #{dataInfo.modifyUserCode},
            #{dataInfo.createTime},
            #{dataInfo.updateTime},
            <if test="paramUserExperienceMaintainList.get(i).popUpsContent!=null and paramUserExperienceMaintainList.get(i).popUpsContent!=''">
                #{dataInfo.popUpsContent},
            </if>

            <if test="paramUserExperienceMaintainList.get(i).popUpsLink!=null and paramUserExperienceMaintainList.get(i).popUpsLink!=''">
                #{dataInfo.popUpsLink}
            </if>
            )
        </foreach>

    </insert>
```

## 示例代码二(如果传入的是map集合,map的entrySet())

```xml

<insert id="XXX" parameterType="java.util.Map">
    INSERT INTO table(a, b)
    VALUES
    <foreach collection="param.entrySet()" open="(" separator="," close=")" index="key" item="val">
        #{key}, #{val}
    </foreach>
  </insert>
</mapper>
```

## 示例代码三(如果传入的是map集合)

```xml
  <insert id="XXX" parameterType="java.util.Map">
    INSERT INTO table
    <foreach collection="params.keys" item="key" open="(" separator="," close=")">
        获取值：#{param[key]}
        键：#{key}
    </foreach>
    VALUES
    <foreach collection="param.value" item="val" open="(" separator="," close=")">
       值：#{val}
    </foreach>
  </insert>
```