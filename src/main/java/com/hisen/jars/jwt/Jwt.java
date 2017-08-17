package com.hisen.jars.jwt;

import com.alibaba.fastjson.JSON;
import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.interfaces.Claim;
import com.auth0.jwt.interfaces.DecodedJWT;
import java.io.UnsupportedEncodingException;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import org.joda.time.DateTime;

/**
 * 利用java-jwt 3.2.0版本
 * 每个版本的方法不大一样
 * Created by hisenyuan on 2017/8/17 at 15:41.
 */
public class Jwt {
  private static final String SECRET = "XX#$%()(#*!()!KL<><MQLMNQNQJQK sdfkjsdrow32234545df>?N<:{LWPW_hisen";
  private static final String EXP = "exp";
  private static final String PAYLOAD = "payload";

  // 加密，传入一个对象和有效期
  public static <T> String sign(T object, long maxAge)
      throws UnsupportedEncodingException {
    Map<String, Object> map = new HashMap<String, Object>();
    String jsonString = JSON.toJSONString(object);
    map.put("alg", "HS256");
    map.put("typ", "JWT");
    long exp = System.currentTimeMillis() + maxAge;
    String token = JWT.create()
        .withHeader(map)//header
        .withClaim(PAYLOAD, jsonString)//存放的内容 json
        .withClaim(EXP, new DateTime(exp).toDate())//超时时间
        .sign(Algorithm.HMAC256(SECRET));//密钥
    return token;
  }

  // 解密，传入一个加密后的token字符串和解密后的类型
  public static <T> T unsign(String token, Class<T> classT) throws UnsupportedEncodingException {
    JWTVerifier verifier = JWT.require(Algorithm.HMAC256(SECRET)).build();
    DecodedJWT jwt = verifier.verify(token);
    Map<String, Claim> claims = jwt.getClaims();
    if (claims.containsKey(EXP) && claims.containsKey(PAYLOAD)) {
      long tokenTime = claims.get(EXP).asDate().getTime();
      long now = new Date().getTime();
      // 判断令牌是否已经超时
      if (tokenTime > now) {
        String json = claims.get(PAYLOAD).asString();
        // 把json转回对象，返回
        return JSON.parseObject(json, classT);
      }
    }
    return null;
  }
}
