<?php

namespace Drupal\tls_checker\Controller;

use Drupal\Core\Controller\ControllerBase;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Drupal\tls_checker\Service\TLSCheckerService;
use Symfony\Component\DependencyInjection\ContainerInterface;
use Drupal\Core\Database\Connection;

/**
 * Processes TLS scan batches.
 */
class TLSCheckerBatchController extends ControllerBase {

  /**
   * TLS Checker Service.
   *
   * @var \Drupal\tls_checker\Service\TLSCheckerService
   */
  protected $tlsCheckerService;

  /**
   * Database connection.
   *
   * @var \Drupal\Core\Database\Connection
   */
  protected $database;

  /**
   * Constructs a TLSCheckerBatchController object.
   */
  public function __construct(TLSCheckerService $tlsCheckerService, Connection $database) {
    $this->tlsCheckerService = $tlsCheckerService;
    $this->database = $database;
  }

  /**
   * {@inheritdoc}
   */
  public static function create(ContainerInterface $container) {
    return new static(
      $container->get('tls_checker.service'),
      $container->get('database')
    );
  }

  /**
   * Processes a batch of URLs and stores results in the database.
   */
  public function processBatch(Request $request) {
    $data = json_decode($request->getContent(), TRUE);
    $urls = $data['urls'] ?? [];

    \Drupal::logger('tls_checker')->debug('Received URLs for batch processing: @urls', ['@urls' => json_encode($urls)]);

    if (empty($urls)) {
      return new JsonResponse(['error' => 'No URLs provided for scanning.'], 400);
    }

    $this->tlsCheckerService->scanAndStoreUrls($urls);

    return new JsonResponse([
      'success' => TRUE,
      'processed' => count($urls),
    ]);
  }

  /**
   * Retrieves the scan results from the TLS Checker service.
   *
   * This method calls the TLS Checker service to get the scan results and
   * returns them as a JSON response.
   *
   * @return \Symfony\Component\HttpFoundation\JsonResponse
   *   The JSON response containing the scan results.
   */
  public function getScanResults() {
    $scanResults = $this->tlsCheckerService->getScanResults();

    return new JsonResponse($scanResults);
  }

  /**
   * Returns a list of URLs for scanning.
   */
  public function getUrlsToScan() {
    $urls = $this->tlsCheckerService->extractUrlsFromCodebase();

    return new JsonResponse([
      'urls_to_scan' => $urls,
    ]);
  }

}
