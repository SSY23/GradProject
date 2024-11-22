const express = require('express');
const axios = require('axios');
const moment = require('moment-timezone');
const router = express.Router();

// OpenWeatherMap API Key
const API_KEY = process.env.OPENWEATHER_API_KEY; // OpenWeatherMap에서 발급받은 API Key

// 날씨 조회 API (위도, 경도 기준)
router.get('/current', async (req, res) => {
  const { lat, lon } = req.query;

  if (!lat || !lon) {
    return res.status(400).json({ error: 'Latitude and longitude are required' });
  }

  try {
    const response = await axios.get('https://api.openweathermap.org/data/2.5/weather', {
      params: {
        lat: lat,
        lon: lon,
        appid: API_KEY,
        units: 'metric',
      },
    });

    const weatherData = response.data;
    const result = {
      temperature: weatherData.main.temp,
      humidity: weatherData.main.humidity,
      wind_speed: weatherData.wind.speed,
      condition: weatherData.weather[0].description,
    };

    // OpenWeatherMap에서 반환하는 시간은 UTC 기준이므로, 이를 현지 시간으로 변환
    const timezone = weatherData.timezone; // timezone (초 단위)
    const localTime = moment.unix(weatherData.dt).tz(moment.tz.guess()).format('YYYY-MM-DD HH:mm:ss');
    result.time = localTime; // 현지 시간 추가

    res.json(result);
  } catch (error) {
    console.error('Weather API error:', error.response ? error.response.data : error.message);
    res.status(500).json({ error: 'Unable to retrieve weather data' });
  }
});

// 하루 종일 날씨 예보 (5일 예보에서 하루치만 필터링)
router.get('/forecast', async (req, res) => {
  const { lat, lon } = req.query;

  if (!lat || !lon) {
    return res.status(400).json({ error: 'Latitude and longitude are required' });
  }

  try {
    const response = await axios.get('https://api.openweathermap.org/data/2.5/forecast', {
      params: {
        lat: lat,
        lon: lon,
        appid: API_KEY,
        units: 'metric',
      },
    });

    const forecastData = response.data.list; // 5일 예보 데이터에서 3시간마다의 날씨 정보
    const timezoneOffset = response.data.city.timezone; // 응답에서 타임존 정보 가져오기 (초 단위)

    // 오늘 날짜 (YYYY-MM-DD)
    const today = moment().format('YYYY-MM-DD'); // 현재 날짜

    // 오늘에 해당하는 시간대만 필터링
    const dailyForecast = forecastData
      .filter(item => {
        const utcTime = moment(item.dt_txt); // UTC 기준 시간
        const localTime = utcTime.utcOffset(timezoneOffset / 60); // 현지 시간으로 변환
        const timeStr = localTime.format('YYYY-MM-DD'); // 현지 시간 날짜

        return timeStr === today; // 오늘 날짜에 해당하는 데이터만 필터링
      })
      .map(item => {
        const utcTime = moment(item.dt_txt); // UTC 기준 시간
        const localTime = utcTime.utcOffset(timezoneOffset / 60); // 현지 시간으로 변환

        return {
          time: localTime.format('HH:mm'), // 시간 정보 (HH:MM)
          temperature: item.main.temp, // 기온
          weather: item.weather[0].description, // 날씨 상태
          wind_speed: item.wind.speed, // 바람 속도
        };
      });

    // 하루 동안의 예보 데이터를 반환
    res.json(dailyForecast);
  } catch (error) {
    console.error('Weather API error:', error.response ? error.response.data : error.message);
    res.status(500).json({ error: 'Unable to retrieve weather forecast data' });
  }
});

module.exports = router;
