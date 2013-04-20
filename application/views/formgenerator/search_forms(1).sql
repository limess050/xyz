-- phpMyAdmin SQL Dump
-- version 3.5.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Apr 19, 2013 at 11:54 AM
-- Server version: 5.5.24-log
-- PHP Version: 5.3.13

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `form_generator`
--

-- --------------------------------------------------------

--
-- Table structure for table `search_forms`
--

CREATE TABLE IF NOT EXISTS `search_forms` (
  `input_type_id` int(11) NOT NULL,
  `category_id` varchar(250) DEFAULT NULL,
  `form_label` varchar(45) DEFAULT NULL,
  `sections_without_subsections` varchar(45) DEFAULT NULL,
  `displayOrder` int(11) DEFAULT NULL,
  `no_input` varchar(45) DEFAULT NULL,
  `input_tip` varchar(45) DEFAULT NULL,
  `parentsectionid` varchar(45) DEFAULT NULL,
  `subsectionid` varchar(45) DEFAULT NULL,
  `categoryid` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `search_forms`
--

INSERT INTO `search_forms` (`input_type_id`, `category_id`, `form_label`, `sections_without_subsections`, `displayOrder`, `no_input`, `input_tip`, `parentsectionid`, `subsectionid`, `categoryid`) VALUES
(108, '32', 'Price', '11', 1, '1', '', NULL, NULL, NULL),
(108, '36', 'Price', '', 1, '1', '', NULL, NULL, NULL),
(108, '18', 'Rent', '5', 1, '1', '', NULL, NULL, NULL),
(126, '18', 'Term', '5', 2, '1', '', NULL, NULL, NULL),
(127, '18', 'Location', '5', 3, '1', '', NULL, NULL, NULL),
(128, '18', 'Amenities', '5', 4, '1', '', NULL, NULL, NULL),
(108, '40', 'Price', '6', 2, '1', '', NULL, NULL, NULL),
(127, '40', 'Location', '6', 1, '1', '', NULL, NULL, NULL),
(108, '41', 'Price', '6', 2, '1', '', NULL, NULL, NULL),
(127, '41', 'Location', '6', 1, '1', '', NULL, NULL, NULL),
(108, '39', 'Rent', '12', 1, '1', '', NULL, NULL, NULL),
(126, '39', 'Term', '12', 2, '1', '', NULL, NULL, NULL),
(127, '39', 'Location', '12', 3, '1', '', NULL, NULL, NULL),
(108, '33', 'Price', '11', 1, '1', '', NULL, NULL, NULL),
(129, '33', 'search by make', '11', 4, '1', '', NULL, NULL, NULL),
(130, '33', 'search by transmission', '11', 5, '1', '', NULL, NULL, NULL),
(131, '33', 'Kilometers (Less than)', '11', 3, '1', '', NULL, NULL, NULL),
(132, '33', '', '11', 6, '1', '', NULL, NULL, NULL),
(136, '33', '', '11', 1, '1', '', NULL, NULL, NULL),
(108, '34', 'Price', '11', 1, '1', '', NULL, NULL, NULL),
(131, '34', 'Kilometers (Less than)', '11', 3, '1', '', NULL, NULL, NULL),
(136, '34', '', '11', 2, '1', '', NULL, NULL, NULL),
(108, '35', 'Price', '11', 1, '1', '', NULL, NULL, NULL),
(131, '35', 'Kilometers (Less than)', '11', 3, '1', '', NULL, NULL, NULL),
(136, '35', '', '11', 2, '1', '', NULL, NULL, NULL),
(133, '', '', '1', 0, '1', '', '1', '1', ''),
(135, '', '', '1', 3, '1', '', '1', '1', ''),
(136, '', '', '1', 1, '1', '', '1', '1', ''),
(135, '', '', '', 0, '1', '', '3', '', ''),
(136, '', '', '', 0, '1', '', '3', '', '');

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
