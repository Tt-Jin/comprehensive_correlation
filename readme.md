# 全方位展示两个变量之间的关系

#### 1. 数据

- 文章提供了原始绘图数据和 Python 代码，绘图前作者使用 completeness 值对 CDS 和 genome length 做了矫正    

#### 2. 点和回归线图

- guides(color = guide_legend(override.aes = list(alpha = 1, size = 5))) 可以自定义图例的外观，override.aes 参数会覆盖默认的图例设置，其中，alpha = 1（即完全不透明），size = 5（即图例中图标的大小），这意味着在图例中显示的标记将不会有任何透明度，并且它们的大小将被调整为5。
- 使用 scale_x_log10() 和 scale_y_log10() 函数可以将坐标转为对数坐标。
- annotation_logticks() 函数可以给对数坐标添加刻度线，包括大中小刻度线，还可以通过函数里面的参数来设置线的长短、方向等。这个函数要发挥作用，还要加上这句 coord_cartesian(clip = "off") 。

#### 3. 边缘直方图

- ggExtra::ggMarginal() 函数可以添加边缘直方图、核密度曲线、箱式图、小提琴图，非常的简单易用，但是可调节的参数有限 。

#### 4. 残差箱式图

- fit <- lm(log(number_of_cds)~log(length), data = df) 使用对数值做线性回归。
- df$number_of_cds_fit <- exp(predict(fit)) 计算并保存预测值，接着就可以用观测值与预测值相减得到残差，然后就可以画箱式图了。
- geom_boxplot() 画箱式图
- stat_boxplot() 给箱式图的两端添加误差线
- geom_signif() 做显著性检验，并添加 p 值的符号。comparisons 参数设置比较组合，test 参数设置检验方法，map_signif_level 参数设置 p 值对应的符号。
- coord_flip() 使图形“倒”下

#### 5. 组合图

- grid::viewport() 函数可以将箱式图按照给定的尺寸和位置插入到主图中， 比较好操作。

#### 

### 最重要的是：

码代码不易，如果你觉得我的教程对你有帮助，请<font face="微软雅黑" size=6 color=#FF0000 >**小红书 - Ttian6688**</font>关注我！！！
