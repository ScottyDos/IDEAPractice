package com.hisen.designpattern.proxy.staticproxy;

/**
 * @author : yhx
 * @date : 2017/11/9 21:45
 * @descriptor : 汽车代理商 - 4S店
 */
public class BuyCarProxy implements BuyCar{
  // 买车的客户
  private Customser customser;
  public BuyCarProxy(Customser customser){
    // 接收买车客户
    this.customser = customser;
  }

  /**
   * 实现为客户买车
   */
  @Override
  public void buyCar() {
    // 实现权限控制
    if (customser.getCash()<100000){
      System.out.println("您的购车款不足！");
    }
    customser.buyCar();
  }
}
