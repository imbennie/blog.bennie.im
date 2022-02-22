title: 设计模式之静态代理模式详解
date: 2015-09-20 20:11:57
tags: 
	- Java
	- 设计模式
	- 静态代理
categories:
	- 设计模式

---

静态代理设计思想

总体思想,通过传递一个被代理类的对象到代理类构造器中的参数,来决定`代理类`去代理哪个`被代理类`.
代理一个被代理类就是`把被代理类的对象传到 代理类的构造器中`,然后去调用已经实现接口中的哪些方法.


1. 需要一个接口,定义一些方法.
然后有好几个被代理类去实现接口中的这些方法,接着有一个代理类也去实现这些方法,
只不过代理类的实现过程是直接调用被代理类中实现好的方法.

2. 举个很形象的例子,就比如你要去XX品牌专卖店买个东西,然后当你和店员谈好价格准备拿货时
老板说哎呀我这里暂时没货,明天我去厂子里给你拿一个之类的话.
老板就好比代理类,具体生产某品牌的商品的厂子就好比是个被代理类.

3. 接口的作用,接口一直都是起到一个定义的作用!就是定义一些必须的操作,让具体的类去实现它.
这就像是说上司给你安排任务,具体怎么做他不管,他关心的是你有没有完成这个任务.

具体看下面的代码和注释,举了个故事情景的例子方便理解.

<!-- more -->

```java

/*
 * 第1步,假设有个鼠标的生厂商,然后有个客户要买个鼠标.但是生厂商只负责生产鼠标
 * 不知道客户具体要买什么鼠标,所以这里定义个接口.
 */

// 这个接口是鼠标生产商
interface MouseProducers {

	// 然后他具有的功能就是生产鼠标.
	void produceMouse();
}

/*
 * 第2步,有两个可以生产鼠标的鼠标生产商.
 */

// 第一个实现类是: 生产雷蛇鼠标的厂商
class RazerMouseProducers implements MouseProducers {

	@Override
	public void produceMouse() {
		System.out.println("我是雷蛇鼠标生产商.");
	}
}

// 第二个实现类是: 生产罗技鼠标的厂商
class LogitMouseProducers implements MouseProducers {

	@Override
	public void produceMouse() {
		System.out.println("我是罗技鼠标生产商.");
	}
}

/*
 * 第3步,某某鼠标专卖店,这个专卖店呢他自己不会生产鼠标,但是他知道在哪可以帮你拿到货.
 * 你要买雷蛇的他就去雷蛇鼠标生产商帮你拿货,你要买罗技的他就去罗技生产商帮你拿货.
 * 就算你以后想买个别的鼠标,他也可以帮你拿到货.(只要我们提供MouseProducers接口的实现类, 他都可以代理帮你拿货)
 */

/*
 * 1. 定义一个鼠标商店类,也让他实现MouseProducers接口,这个MouseStore类就称为代理类.
 * 为什么要让他实现呢? 你想啊,他是卖鼠标的, 他得假装他会生产鼠标是吧?
 * 所以说他要实现这个接口,而且还要接口中的方法.
 * 
 * 2. 方法实现完了,我们还需要写个构造器.而且还是有参数的.
 * 
 * 	2.1 为什么要是有参数的?
 * 	作为卖鼠标的商店,客户得告诉他要买什么鼠标,他才能去拿货是不是.
 * 	所以我们写个带参数的构造器, 让参数来告诉他要什么样的鼠标.
 * 
 * 	2.2 要有什么参数? 雷蛇类的鼠标还是罗技类的鼠标呢?
 * 	啪! 都不是, 因为你想啊, 你要是写死了的话, 那我们来假设下, 如果来2个客户, 一个要雷蛇的, 一个要罗技的.
 * 	你能告诉他们你家只卖一种鼠标吗? 所以说我们要写MouseProducers这个接口的实例.
 * 	然后等客户要买啥鼠标, 我们再new一个这个接口的实现类的对象给他.(这个就是面向对象中美妙的多态性啦!)
 */
class MouseStore implements MouseProducers {

	private MouseProducers mouseProducers;

	// 这里用接口来定义对象是因为传递过来的对象是其实现类的其中一个.
	public MouseStore(MouseProducers mouseProducers) {
		this.mouseProducers = mouseProducers;
	}

	@Override
	public void produceMouse() {
		// 这时候再去调用接口实现类中的方法就可以了.
		mouseProducers.produceMouse();
	}

}

public class StaticProxyModelTest {

	public static void main(String[] args) {

		// 假设2个客户 第一个买雷蛇 第二个买罗技
		MouseProducers mp_1 = new RazerMouseProducers();
		MouseStore mouseStore_1 = new MouseStore(mp_1);
		mouseStore_1.produceMouse();

		MouseProducers mp_2 = new LogitMouseProducers();
		MouseStore mouseStore_2 = new MouseStore(mp_2);
		mouseStore_2.produceMouse();

	}
}
```