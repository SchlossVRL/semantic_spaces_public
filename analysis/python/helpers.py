
import numpy as np
import sklearn
import pandas as pd
from numpy.linalg import inv, svd
from itertools import combinations
from sklearn import linear_model as lm
import warnings
warnings.filterwarnings('ignore')



uw71coords = pd.read_csv('../../data/UW71coordinates_long.csv')
uw71coords['hue_angle'] = uw71coords.apply( lambda x: colorsys.rgb_to_hls(*list( hex_to_rgb(x.color_hex)))[0], axis=1)
uw71coords['saturation'] = uw71coords.apply( lambda x: colorsys.rgb_to_hls(*list( hex_to_rgb(x.color_hex)))[1], axis=1)
uw71coords['lightness'] = uw71coords.apply( lambda x: colorsys.rgb_to_hls(*list( hex_to_rgb(x.color_hex)))[2], axis=1)


def colorimetric_reg(pc):
    regressors = np.array((uw71coords['L'],np.cos(uw71coords['H']*(np.pi/180)),\
                 np.sin(uw71coords['H']*(np.pi/180)),np.cos(2*uw71coords['H']*(np.pi/180)),\
                 np.sin(2*uw71coords['H']*(np.pi/180)),uw71coords['C']))

    model = lm.LinearRegression(fit_intercept=True).fit(regressors.T, pc.reshape(71,1))
    preds = model.predict(regressors.T)

    return(np.append(m.intercept_,m.coef_)),preds ## weights and predictions

